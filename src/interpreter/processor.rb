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
        @current_scope.tokens << @lexer.next_token
      end
      @current_scope.current_token
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
      when Token::PROPERTY
        # TODO: feature/properties
      when Token::ARRAY_BEGIN
        # TODO: feature/assignment-lists
      end

      if token.sub_type == Token::VARIABLE
        @current_scope.set_variable token.content, value
      elsif token.sub_type == Token::VAR_ARE
        @are = value
      end

      @sore = value
    end

    def process_debug(debug_token)
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
      when Token::VAL_ARRAY then []
      when Token::VAR_SORE  then @sore.dup
      when Token::VAR_ARE   then @are.dup
      when Token::VARIABLE  then @current_scope.get_variable token.content
      end
    end

    # TODO: feature/interpreter-properties
    # def resolve_property(property_token, attribute_token)
    # end
  end
end
