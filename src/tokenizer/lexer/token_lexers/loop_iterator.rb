module Tokenizer
  class Lexer
    module TokenLexers
      def loop_iterator?(chunk)
        chunk =~ /^(対|たい)して$/
      end

      # If stack size is 1: the loop iterator parameter is a variable or string.
      # If stack size is 2: the loop iterator parameter is a property and key attribute. (v1.1.0)
      def process_loop_iterator(_chunk)
        validate_loop_iterator_parameter @stack[-1], @stack[-2]

        (@stack << Token.new(Token::LOOP_ITERATOR)).last
      end
    end
  end
end
