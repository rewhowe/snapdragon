module Tokenizer
  class Lexer
    module TokenLexers
      def comp_1_lteq?(chunk)
        chunk =~ /.+以下\z/
      end

      def tokenize_comp_1_lteq(chunk)
        @stack << comp_token(chunk.chomp('以下'))
        Token.new Token::COMP_1_LTEQ
      end
    end
  end
end
