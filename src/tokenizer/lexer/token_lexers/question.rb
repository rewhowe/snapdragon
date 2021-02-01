module Tokenizer
  class Lexer
    module TokenLexers
      def question?(chunk)
        chunk =~ /\A[#{QUESTION}]\z/
      end

      def tokenize_question(_chunk)
        (@stack << Token.new(Token::QUESTION)).last
      end
    end
  end
end
