module Tokenizer
  class Lexer
    module TokenLexers
      def comp_1_yori?(chunk)
        chunk =~ /.+より$/
      end

      def tokenize_comp_1_yori(chunk)
        @stack << comp_token(chunk.chomp('より'))
        Token.new Token::COMP_1_YORI
      end
    end
  end
end
