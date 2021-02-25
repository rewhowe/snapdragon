require_relative '../colour_string'
require_relative '../token'
require_relative '../util/logger'
require_relative '../util/options'
require_relative '../tokenizer/constants'
require_relative '../tokenizer/oracles/property'

require_relative 'errors'
require_relative 'formatter'
require_relative 'return_value'
require_relative 'scope'

require_relative 'processor/built_ins'
Dir["#{__dir__}/processor/token_processors/*.rb"].each { |f| require_relative f }

module Interpreter
  class Processor
    MAX_CALL_STACK_DEPTH = 1000

    ############################################################################
    # TokenProcessors consist of processing methods and any processing-specific
    # helper methods.
    #
    # Processing:
    # These methods take tokens and execute them. They may also read from the
    # stack or additional tokens in the token stream. The stack should be clear
    # after each call to a processing method.
    #
    # Any other common or helper methods will be in this file.
    ############################################################################
    include TokenProcessors

    include BuiltIns

    def initialize(lexer, options = {})
      @lexer   = lexer
      @options = options

      @current_scope = Scope.new

      # The current stack of tokens which have not been processed.
      @stack = []
    end

    def execute
      process
    rescue Errors::BaseError => e
      e.line_num = @lexer.line_num
      raise
    end

    private

    def process
      raise Errors::CallStackTooDeep, MAX_CALL_STACK_DEPTH if caller.length > MAX_CALL_STACK_DEPTH

      loop do
        token = next_token
        break if token.nil?

        result = process_token token
        return result if result.is_a? ReturnValue
      end

      nil
    end

    # If this is the main scope, tokens are read from the lexer and discarded.
    # Otherwise, the tokens of other types of scopes are stored in their bodies
    # and kept track of using a token pointer.
    # Returns the current token under the token pointer and then optionally
    # advances it.
    def next_token(options = { should_advance?: true })
      if @current_scope.type == Scope::TYPE_MAIN
        token = @lexer.next_token
        @current_scope.tokens << token unless token.nil?
      end

      token = @current_scope.current_token

      if options[:should_advance?]
        Util::Logger.debug Util::Options::DEBUG_2, 'RECEIVE: '.lred + (token ? "#{token} #{token.content}" : 'EOF')
        @current_scope.advance
      end

      token
    end

    def peek_next_token
      next_token should_advance?: false
    end

    def next_token_if(token_type)
      next_token if peek_next_token&.type == token_type
    end

    # Accumulates tokens until the requested token type.
    # If searching for a SCOPE_CLOSE: skips pairs of matching SCOPE_BEGINS and
    # SCOPE_CLOSEs.
    def next_tokens_until(token_type, options = { inclusive?: true })
      [].tap do |tokens|
        open_count = 0

        loop do
          peeked_token = peek_next_token

          open_count += 1 if token_type == Token::SCOPE_CLOSE && peeked_token.type == Token::SCOPE_BEGIN

          if peeked_token.type == token_type
            break if open_count.zero?
            open_count -= 1
          end

          tokens << next_token
        end

        tokens << next_token if options[:inclusive?]
      end
    end

    def next_tokens_from_scope_body
      next_token # discard scope open
      body_tokens = next_tokens_until Token::SCOPE_CLOSE
      body_tokens.pop # discard scope close
      body_tokens
    end

    # Calls the associated processing method if the current token can lead to
    # meaningful execution. Otherwise, stores the token in the stack to be
    # processed later.
    def process_token(token)
      token_type = token.type.to_s
      method = "process_#{token_type}"
      if respond_to? method, true
        Util::Logger.debug Util::Options::DEBUG_2, 'PROCESS: '.lyellow + token_type
        return send method, token
      end
      @stack << token
    end

    # Helpers
    ############################################################################

    # rubocop:disable Metrics/CyclomaticComplexity
    def resolve_variable!(tokens)
      token = tokens.shift

      value = begin
        case token.sub_type
        when Token::VAL_NUM   then token.content.to_f
        when Token::VAL_STR   then resolve_string token.content
        when Token::VAL_TRUE  then true
        when Token::VAL_FALSE then false
        when Token::VAL_NULL  then nil
        when Token::VAL_ARRAY then []
        when Token::VAR_SORE  then copy_special @sore
        when Token::VAR_ARE   then copy_special @are
        when Token::VARIABLE  then copy_special @current_scope.get_variable token.content
        end
      end

      return resolve_property value, tokens.shift if token.type == Token::POSSESSIVE

      value
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def resolve_string(value)
      # Remove opening / closing quotes
      value = value.gsub(/^「/, '').gsub(/」$/, '')

      # Escape closing quotes
      value = value.gsub(/\\」/, '」')

      # Check for string interpolation and pass substitutions back to lexer
      value = resolve_string_interpolation value

      # Handling even/odd backslashes is too messy in regex: brute-force
      value = value.gsub(/(\\*n)/) { |match| match.length.even? ? match.gsub(/\\n/, "\n") : match  }
      value = value.gsub(/(\\*￥ｎ)/) { |match| match.length.even? ? match.gsub(/￥ｎ/, "\n") : match  }

      # Finally remove additional double-backslashes
      value.gsub(/\\\\/, '\\')
    end

    def resolve_string_interpolation(value)
      value.gsub(/\\*【[^】]*】?/) do |match|
        next match.sub(/^\\/, '') if match.match(/^(\\+)/)&.captures&.first&.length.to_i.odd?

        interpolation_tokens = @lexer.interpolate_string match

        validate_interpolation_tokens interpolation_tokens

        Formatter.interpolated resolve_variable! interpolation_tokens
      end
    end

    # TODO: (v1.1.0) Properties other than PROP_LEN have not been tested.
    def resolve_property(property_owner, property_token)
      validate_type [Array, String], property_owner

      case property_token.sub_type
      when Token::PROP_LEN  then property_owner.length
      when Token::KEY_INDEX then property_owner[property_token.content.to_i]
      when Token::KEY_NAME  then property_owner[resolve_string(property_token.content)]
      when Token::KEY_VAR   then property_owner[resolve_variable!([property_token])]
      end
    end

    def copy_special(value)
      [String, Array, Hash].include?(value.class) ? value.dup : value
    end

    def boolean_cast(value)
      return !value.zero?  if value.is_a? Numeric
      return !value.empty? if value.is_a?(String) || value.is_a?(Array)
      return false         if value.is_a?(FalseClass)
      !value.nil?
    end

    def resolve_array!
      tokens = next_tokens_until Token::ARRAY_CLOSE
      tokens.pop # discard close
      value = [].tap do |elements|
        tokens.chunk { |t| t.type == Token::COMMA } .each do |is_comma, chunk|
          next if is_comma

          value = resolve_variable! chunk
          value = boolean_cast value if chunk.last&.type == Token::QUESTION

          elements << value
        end
      end
    end

    def resolve_function_arguments_from_stack!
      [].tap { |a| a << resolve_variable!(@stack) until @stack.empty? }
    end

    # TODO: (v1.1.0) Check for possessive in the stack
    def set_variable(token, value)
      if token.sub_type == Token::VARIABLE
        @current_scope.set_variable token.content, value
      elsif token.sub_type == Token::VAR_ARE
        @are = value
      end
    end

    def function_indentifiers_from_stack(token)
      parameter_particles = @stack.map(&:particle).compact
      [token.content + parameter_particles.sort.join, parameter_particles]
    end

    def validate_type(types, value)
      return if [*types].any? { |type| value.is_a? type }
      raise Errors::InvalidType.new [*types].join(' or '), Formatter.output(value)
    end

    def validate_interpolation_tokens(interpolation_tokens)
      substitute_token, property_token = interpolation_tokens[0, 1]
      if substitute_token.sub_type == Token::VARIABLE && !@current_scope.variable?(substitute_token.content)
        raise Errors::VariableDoesNotExist, substitute_token.content
      end

      # TODO: feature/associative-arrays test
      return if property_token&.sub_type != Token::KEY_VAR || @current_scope.variable?(property_token.content)
      raise Errors::PropertyDoesNotExist, property_token.content
    end
  end
end
