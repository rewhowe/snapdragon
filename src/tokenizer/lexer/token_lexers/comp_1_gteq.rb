module Tokenizer
  class Lexer
    module TokenLexers
      def comp_1_gteq?(chunk)
        chunk =~ /.+以上\z/
      end

      def tokenize_comp_1_gteq(chunk)
        @stack << comp_token(chunk.chomp('以上'))
        Token.new Token::COMP_1_GTEQ
      end
    end
  end
end
