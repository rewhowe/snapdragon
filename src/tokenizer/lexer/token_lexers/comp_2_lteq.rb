module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_lteq?(chunk)
        chunk =~ /.+以下$/
      end

      def process_comp_2_lteq(chunk)
        @stack << comp_token(chunk.chomp('以下'))
        Token.new Token::COMP_2_LTEQ
      end
    end
  end
end
