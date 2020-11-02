module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_to?(chunk)
        chunk =~ /.+と$/
      end

      def process_comp_2_to(chunk)
        @stack << comp_token(chunk.chomp('と'))
        Token.new Token::COMP_2_TO
      end
    end
  end
end
