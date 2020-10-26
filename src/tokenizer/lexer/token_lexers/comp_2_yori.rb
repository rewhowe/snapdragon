module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_yori?(chunk)
        chunk =~ /.+より$/
      end

      def process_comp_2_yori(chunk)
        @stack << comp_token(chunk.chomp('より'))
        Token.new Token::COMP_2_YORI
      end
    end
  end
end
