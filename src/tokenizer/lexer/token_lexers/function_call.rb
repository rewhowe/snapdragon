module Tokenizer
  class Lexer
    module TokenLexers
      def function_call?(chunk)
        # @current_scope.function?(chunk, signature_from_stack) && (
        #   @last_token_type == Token::EOL                               ||
        #   (@last_token_type == Token::PARAMETER && !parameter?(chunk)) ||
        #   question?(@reader.peek_next_chunk) # must be an if / else-if
        # )
        @current_scope.function? chunk, signature_from_stack
      end

      def process_function_call(chunk)
        destination = @context.inside_if_condition? ? @stack : @tokens

        signature = signature_from_stack
        function = @current_scope.get_function chunk, signature

        function_call_parameters_from_stack(function).each { |t| destination << t }

        token = Token.new(
          Token::FUNCTION_CALL,
          function[:name],
          sub_type: function[:built_in?] ? Token::FUNC_BUILT_IN : Token::FUNC_USER
        )
        (destination << token).last
      end
    end
  end
end
