module Tokenizer
  class Lexer
    module TokenLexers
      def comp_1?(chunk)
        chunk =~ /.+が$/
      end

      def process_comp_1(chunk)
        @stack << comp_token(chunk.chomp('が'))
        Token.new Token::COMP_1
      end
    end
  end
end
