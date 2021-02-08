module Tokenizer
  class Lexer
    module TokenLexers
      def bang?(chunk)
        chunk =~ /\A[#{BANG}]\z/
      end

      def tokenize_bang(_chunk)
        (@stack << Token.new(Token::BANG)).last
      end
    end
  end
end
