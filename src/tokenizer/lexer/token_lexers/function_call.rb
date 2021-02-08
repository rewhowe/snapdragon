module Tokenizer
  class Lexer
    module TokenLexers
      def function_call?(chunk)
        @current_scope.function? chunk, signature_from_stack
      end

      def tokenize_function_call(chunk)
        function = @current_scope.get_function chunk, signature_from_stack

        @stack += function_call_parameters_from_stack! function

        token = Token.new(
          Token::FUNCTION_CALL,
          function[:name],
          sub_type: function[:built_in?] ? Token::FUNC_BUILT_IN : Token::FUNC_USER
        )
        (@stack << token).last
      end
    end
  end
end
