module Tokenizer
  class Lexer
    module TokenLexers
      def bang?(chunk)
        chunk =~ /\A[#{BANG}]\z/
      end

      # Discards the bang for function definitions (it was already processed).
      def tokenize_bang(_chunk)
        (@stack << Token.new(Token::BANG)).last unless @context.last_token_type == Token::FUNCTION_DEF
      end
    end
  end
end
