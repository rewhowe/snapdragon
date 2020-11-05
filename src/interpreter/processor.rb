require_relative '../colour_string'
require_relative '../token'
require_relative '../util/logger'

require_relative 'scope'

module Interpreter
  class Processor
    def initialize(lexer, options = {})
      @lexer   = lexer
      @options = options

      @current_scope = Scope.new

      # The current stack of tokens to be processed.
      @stack = []
    end

    def process
      loop do
        token = next_token
        break if token.nil?

        value = process_token token
        return value if value.is_a? ReturnValue
      end

      nil
    end

    private

    class ReturnValue
      attr_reader :value
      def initialize(value)
        @value = value
      end
    end

    def next_token
      token = peek_next_token
      Util::Logger.debug Util::Options::DEBUG_2, 'RECEIVE: '.lred + [token, token&.content || 'EOF'].compact.join(' ')
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

    def accept_until(token_type, options = { inclusive?: true })
      [].tap do |tokens|
        while peek_next_token.type != token_type
          tokens << next_token
        end
        tokens << next_token if options[:inclusive?]
      end
    end

    def process_token(token)
      token_type = token.type.to_s
      method = "process_#{token_type}"
      return send method, token if respond_to? method, true
      @stack << token
    end

    # Processors
    # TODO: (v1.0.0) Move these out similarly to the lexer
    ############################################################################

    def process_assignment(token)
      # TODO: (v1.1.0) Check for property in the stack
      value_token = next_token

      case value_token.type
      when Token::RVALUE
        value = resolve_variable value_token
        if peek_next_token&.type == Token::QUESTION
          next_token # discard question
          value = boolean_cast value
        end
      when Token::PROPERTY
        # TODO: feature/properties
      when Token::ARRAY_BEGIN
        tokens = accept_until Token::ARRAY_CLOSE
        tokens.pop # discard close
        value = [].tap do |elements|
          tokens.chunk { |t| t.type == Token::COMMA } .each do |is_comma, chunk|
            next if is_comma

            case chunk[0].type
            when Token::RVALUE
              value = resolve_variable chunk[0]
              value = boolean_cast value if chunk[1]&.type == Token::QUESTION
            when Token::PROPERTY
              # TODO: feature/properties
            end

            elements << value
          end
        end
      end

      if token.sub_type == Token::VARIABLE
        @current_scope.set_variable token.content, value
      elsif token.sub_type == Token::VAR_ARE
        @are = value
      end

      @sore = value

      Util::Logger.debug Util::Options::DEBUG_2, "#{token.content} = #{value} (#{value.class})".lpink
    end

    def process_debug(_token)
      Util::Logger.debug Util::Options::DEBUG_3, "#{@current_scope.to_s}\nそれ: #{@sore}\nあれ: #{@are}".lblue
      exit if peek_next_token&.type == Token::BANG
    end

    # TODO: feature/interpreter-function-def
    # def process_function_def(def_token)
    #   # Get parameters
    #   # Define unique key using particles.sort + function name (same as tokenizer scope?)
    #   # Maybe skip if function already defined?
    #   # Make a new function scope and fill tokens until scope_close
    # end

    # TODO: feature/interpreter-function-call
    # def process_function_call(call_token)
    #   # Get parameters
    #   # Define unique key using particles.sort + function name (same as tokenizer scope?)
    #   # Get function from current scope (or parent?)
    #   # # TODO: feature/interpreter-built-ins
    #   # # If built-in, delegate to built-in function methods instead
    #   # Save current scope
    #   # Set current scope to function scope, reset pointer
    #   # Call process
    #   # @sore = return_value.value
    #   # Set current scope to save state
    # end

    # TODO: feature/interpreter-loop
    # def process_loop(loop_token)
    #   # Get parameters
    #   # Make a new scope and fill with tokens until scope_close
    #   # From (start_parameter || 0) to (end_parameter || Float::Infinity)
    #   # @sore = loop index
    #   # Call process
    #   # If !return_value.is_a?(ReturnValue) || return_value.value == Token::NEXT, continue
    #   # If return_value.value == Token::BREAK, break
    #   # Else return return_value
    # end

    # Helpers
    ############################################################################

    def resolve_variable(token)
      case token.sub_type
      when Token::VAL_NUM   then token.content.to_i
      when Token::VAL_STR   then token.content.tr '「」', ''
      when Token::VAL_TRUE  then true
      when Token::VAL_FALSE then false
      when Token::VAL_NULL  then nil
      when Token::VAL_ARRAY then []
      when Token::VAR_SORE  then copy_special @sore
      when Token::VAR_ARE   then copy_special @are
      when Token::VARIABLE  then @current_scope.get_variable token.content
      end
    end

    # TODO: feature/interpreter-properties
    # def resolve_property(property_token, attribute_token)
    # end

    def copy_special(value)
      value.is_a?(String) || value.is_a?(Array) ? value.dup : value
    end

    def boolean_cast(value)
      return false if value.is_a?(Fixnum) && value.zero?
      value.is_a?(String) || value.is_a?(Array) ? !value.empty? : !!value
    end
  end
end
