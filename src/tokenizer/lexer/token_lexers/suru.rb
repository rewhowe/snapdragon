module Tokenizer
  class Lexer
    module TokenLexers
      def suru?(chunk)
        chunk == 'する'
      end

      def tokenize_suru(_chunk)
        Token.new Token::SURU # for flavour
      end
    end
  end
end
