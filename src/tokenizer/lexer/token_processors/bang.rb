module Tokenizer
  class Lexer
    module TokenProcessors
      def bang?(chunk)
        chunk =~ /^[#{BANG}]$/
      end

      def process_bang(_chunk)
        (@tokens << Token.new(Token::BANG)).last
      end
    end
  end
end
