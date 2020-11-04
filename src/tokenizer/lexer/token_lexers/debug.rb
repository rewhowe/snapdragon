module Tokenizer
  class Lexer
    module TokenLexers
      def debug?(chunk)
        chunk == '蛾'
      end

      def process_debug(_chunk)
        (@stack << Token.new(Token::DEBUG)).last
      end
    end
  end
end
