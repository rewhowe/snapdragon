module Tokenizer
  class Lexer
    module TokenLexers
      def loop_iterator?(chunk)
        chunk =~ /^(対|たい)して$/
      end

      # If stack size is 1: the loop iterator parameter is a variable or string.
      # If stack size is 2: the loop iterator parameter is a property and key attribute. (v1.1.0)
      def process_loop_iterator(_chunk)
        # TODO: remove
        raise Errors::UnexpectedLoop if ![1, 2].include?(@tokens.size) || @context.inside_if_condition?

        validate_loop_iterator_parameter @tokens[-1], @tokens[-2]

        (@tokens << Token.new(Token::LOOP_ITERATOR)).last
      end
    end
  end
end
