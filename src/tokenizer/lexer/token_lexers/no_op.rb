module Tokenizer
  class Lexer
    module TokenLexers
      def no_op?(chunk)
        chunk == '・・・'
      end

      def tokenize_no_op(_chunk)
        (@stack << Token.new(Token::NO_OP)).last
      end
    end
  end
end
