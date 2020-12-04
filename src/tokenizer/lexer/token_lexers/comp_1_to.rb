module Tokenizer
  class Lexer
    module TokenLexers
      def comp_1_to?(chunk)
        chunk =~ /.+と$/
      end

      def tokenize_comp_1_to(chunk)
        @stack << comp_token(chunk.chomp('と'))
        Token.new Token::COMP_1_TO
      end
    end
  end
end
