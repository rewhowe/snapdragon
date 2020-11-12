require_relative '../colour_string'
require_relative '../token'
require_relative '../util/logger'
require_relative '../util/options'

require_relative 'errors'
require_relative 'formatter'
require_relative 'return_value'
require_relative 'scope'

require_relative 'processor/built_ins'

module Interpreter
  class Processor

    MAX_CALL_STACK_DEPTH = 1000;

    include BuiltIns

    def initialize(lexer, options = {})
      @lexer   = lexer
      @options = options

      @current_scope = Scope.new

      # The current stack of tokens to be processed.
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
    def accept_until(token_type, options = { inclusive?: true })
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

    def accept_scope_body
      next_token # discard scope open
      body_tokens = accept_until Token::SCOPE_CLOSE
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

    # Processors
    # TODO: (v1.0.0) Move these out similarly to the lexer
    ############################################################################

    def process_assignment(token)
      # TODO: (v1.1.0) Check for property in the stack
      value_token = next_token

      case value_token.type
      when Token::RVALUE, Token::PROPERTY
        value = resolve_variable! [value_token, next_token_if(Token::ATTRIBUTE)]
        value = boolean_cast value if !next_token_if(Token::QUESTION).nil?
      when Token::ARRAY_BEGIN
        tokens = accept_until Token::ARRAY_CLOSE
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

      # TODO: (v1.1.0) Check for property in the stack
      if token.sub_type == Token::VARIABLE
        @current_scope.set_variable token.content, value
      elsif token.sub_type == Token::VAR_ARE
        @are = value
      end

      @sore = value

      Util::Logger.debug Util::Options::DEBUG_2, "#{token.content} = #{value} (#{value.class})".lpink
    end

    def process_debug(_token)
      debug_message = [
        @current_scope.to_s,
        'それ: ' + Formatter.output(@sore),
        'あれ: ' + Formatter.output(@are),
      ].join "\n"
      Util::Logger.debug Util::Options::DEBUG_3, debug_message.lblue
      exit if peek_next_token&.type == Token::BANG
    end

    def process_no_op(_token)
      # pass
    end

    def process_function_def(token)
      parameter_particles = @stack.map(&:particle)
      function_key = token.content + parameter_particles.sort.join

      # skip if already defined
      return if @current_scope.get_function function_key, bubble_up?: false

      body_tokens = accept_scope_body
      @current_scope.define_function function_key, body_tokens, @stack.map(&:content)

      @stack.clear

      Util::Logger.debug Util::Options::DEBUG_2, "define #{token.content} (#{parameter_particles.join ','})".lpink
    end

    def process_function_call(token)
      parameter_particles = @stack.map(&:particle).compact
      function_key = token.content + parameter_particles.sort.join

      arguments = @stack.dup
      resolved_arguments = [].tap { |a| a << resolve_variable!(@stack) until @stack.empty? }

      Util::Logger.debug(
        Util::Options::DEBUG_2,
        "call #{resolved_arguments.zip(parameter_particles).map(&:join).join}#{token.content}".lpink
      )

      is_loud = !next_token_if(Token::BANG).nil?
      is_inquisitive = !next_token_if(Token::QUESTION).nil?

      if token.sub_type == Token::FUNC_BUILT_IN
        return delegate_built_in token.content, arguments, allow_error?: is_loud, cast_to_boolean?: is_inquisitive
      end

      function = @current_scope.get_function function_key

      function.parameters.zip(resolved_arguments).each do |name, argument|
        function.set_variable name, argument
      end

      current_scope = @current_scope # save current scope
      @current_scope = function      # swap current scope with function
      @current_scope.reset           # reset the token pointer
      begin
        @sore = process.value        # process function tokens
        @sore = boolean_cast @sore if is_inquisitive
      rescue Errors::BaseError => e
        raise e if is_loud
        @sore = nil
      end
      @current_scope = current_scope # replace current scope
    end

    def process_return(_token)
      ReturnValue.new resolve_variable! @stack
    end

    def process_loop(_token)
      start_index = 0
      end_index = Float::INFINITY

      if @stack.last&.type == Token::LOOP_ITERATOR
        target = resolve_variable! @stack
        @stack.clear # discard iterator
        validate_type [Array, String], target
        end_index = target.length
      elsif !@stack.empty?
        start_index = resolve_variable!(@stack).to_i
        end_index = resolve_variable!(@stack).to_i
      end

      body_tokens = accept_scope_body

      current_scope = @current_scope                                           # save current scope
      @current_scope = Scope.new @current_scope, Scope::TYPE_LOOP, body_tokens # swap current scope with loop scope

      Util::Logger.debug Util::Options::DEBUG_2, "loop from #{start_index} to #{end_index}".lpink

      result = nil
      loop_range(start_index, end_index).each do |i|
        @current_scope.reset
        @sore = target ? target[i] : i
        result = process
        if result.is_a? ReturnValue
          next if result.value == Token::NEXT
          break
        end
      end

      @current_scope = current_scope # replace current scope

      result if result.is_a?(ReturnValue) && result.value != Token::BREAK
    end

    def process_next(_token)
      ReturnValue.new Token::NEXT
    end

    def process_break(_token)
      ReturnValue.new Token::BREAK
    end

    def process_if(_token)
      loop do
        comparator_token = next_token

        comparison_result = process_if_condition comparator_token

        body_tokens = accept_scope_body

        if comparison_result
          result = process_if_body body_tokens

          while [Token::ELSE_IF, Token::ELSE].include? peek_next_token&.type
            accept_until Token::SCOPE_BEGIN # discard condition
            accept_until Token::SCOPE_CLOSE # discard body
          end

          return result
        elsif next_token_if Token::ELSE_IF
          next
        elsif next_token_if Token::ELSE
          body_tokens = accept_scope_body

          return process_if_body body_tokens
        else
          break
        end
      end
    end

    # Helpers
    ############################################################################

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

    def validate_type(types, value)
      return if [*types].any? { |type| value.is_a? type }
      raise Errors::InvalidType.new [*types].join('or'), Formatter.output(value)
    end

    def loop_range(start_index, end_index)
      start_index <= end_index ? start_index.upto(end_index - 1) : start_index.downto(end_index + 1)
    end

    def process_if_condition(comparator_token)
      comparison_tokens = accept_until Token::SCOPE_BEGIN, inclusive?: false

      function_call_token_index = comparison_tokens.index { |t| t.type == Token::FUNCTION_CALL }
      if function_call_token_index
        function_call_token = comparison_tokens.slice! function_call_token_index
        @stack = comparison_tokens

        process_function_call function_call_token
        comparison_result = comparator_token.type == Token::COMP_EQ ? @sore : !@sore

        Util::Logger.debug Util::Options::DEBUG_2, "if function call (#{comparison_result})".lpink
      else
        value1 = resolve_variable! comparison_tokens
        value2 = resolve_variable! comparison_tokens
        value2 = boolean_cast value2 if comparison_tokens.last&.type == Token::QUESTION

        comparator = {
          Token::COMP_LT   => :'<',
          Token::COMP_LTEQ => :'<=',
          Token::COMP_EQ   => :'==',
          Token::COMP_NEQ  => :'!=',
          Token::COMP_GTEQ => :'>=',
          Token::COMP_GT   => :'>',
        }[comparator_token.type]

        comparison_result = [value1, value2].reduce comparator

        Util::Logger.debug Util::Options::DEBUG_2, "if #{value1} #{comparator} #{value2} (#{comparison_result})".lpink
      end

      comparison_result
    end

    def process_if_body(body_tokens)
      current_scope = @current_scope                                               # save current scope
      @current_scope = Scope.new @current_scope, Scope::TYPE_IF_BLOCK, body_tokens # swap current scope with if scope

      result = process

      @current_scope = current_scope # replace current scope

      result
    end
  end
end
