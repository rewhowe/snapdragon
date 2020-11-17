module Tokenizer
  class Lexer
    module TokenLexers
      def if?(chunk)
        chunk == 'もし'
      end

      def tokenize_if(_chunk)
        (@stack << Token.new(Token::IF)).last
      end
    end
  end
end
