module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2?(chunk)
        # TODO: should check variable?
        !chunk.empty? && question?(@reader.peek_next_chunk)
      end

      def process_comp_2(chunk)
        @stack << comp_token(chunk)
        Token.new Token::COMP_2
      end
    end
  end
end
