module Tokenizer
  class Lexer
    module TokenLexers
      def no_op?(chunk)
        chunk == '・・・'
      end

      def process_no_op(_chunk)
        (@tokens << Token.new(Token::NO_OP)).last
      end
    end
  end
end
