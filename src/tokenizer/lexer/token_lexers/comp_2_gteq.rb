module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_gteq?(chunk)
        chunk =~ /.+以上$/
      end

      def process_comp_2_gteq(chunk)
        @tokens  << comp_token(chunk.chomp('以上'))
        Token.new Token::COMP_2_GTEQ
      end
    end
  end
end
