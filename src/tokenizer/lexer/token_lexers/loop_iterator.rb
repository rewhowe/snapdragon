module Tokenizer
  class Lexer
    module TokenLexers
      def loop_iterator?(chunk)
        chunk =~ /^(対|たい)して$/
      end

      # If stack size is 1: the loop iterator parameter is a variable or string.
      # If stack size is 2: the loop iterator parameter is a property and key attribute. (v1.1.0)
      def process_loop_iterator(_chunk)
        raise Errors::UnexpectedLoop if ![1, 2].include?(@stack.size) || @context.inside_if_condition?

        parameter_token = @stack.pop
        property_token = @stack.pop
        validate_loop_iterator_parameter parameter_token, property_token

        @tokens << parameter_token
        (@tokens << Token.new(Token::LOOP_ITERATOR)).last
      end
    end
  end
end
