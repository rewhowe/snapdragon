require_relative '../colour_string'
require_relative '../token'
require_relative '../util/logger'
require_relative '../util/options'

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

    def next_token
      token = peek_next_token
      Util::Logger.debug Util::Options::DEBUG_2, 'RECEIVE: '.lred + (token ? "#{token} #{token.content}" : 'EOF')
      @current_scope.advance
      token
    end

    def peek_next_token
      if @current_scope.type == Scope::TYPE_MAIN
        token = @lexer.next_token
        @current_scope.tokens << token unless token.nil?
      end
      @current_scope.current_token
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
        when Token::VAL_STR   then token.content.gsub(/^「/, '').gsub(/」$/, '')
        when Token::VAL_TRUE  then true
        when Token::VAL_FALSE then false
        when Token::VAL_NULL  then nil
        when Token::VAL_ARRAY then []
        when Token::VAR_SORE  then copy_special @sore
        when Token::VAR_ARE   then copy_special @are
        when Token::VARIABLE  then copy_special @current_scope.get_variable token.content
        end
      end

      return resolve_property value, tokens.shift if token.type == Token::PROPERTY

      value
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    # TODO: (v1.1.0) Attributes other than ATTR_LEN have not been tested.
    def resolve_property(property_owner, attribute_token)
      case attribute_token.sub_type
      when Token::ATTR_LEN  then property_owner.length
      when Token::KEY_INDEX then property_owner[atribute_token.content.to_i]
      when Token::KEY_NAME  then property_owner[attribute_token.content.gsub(/^「/, '').gsub(/」$/, '')]
      when Token::KEY_VAR   then property_owner[resolve_variable!([attribute_token])]
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

    def resolve_array
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

    # TODO: (v1.1.0) Check for property in the stack
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
      raise Errors::InvalidType.new [*types].join('or'), Formatter.output(value)
    end
  end
end
