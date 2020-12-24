module Tokenizer
  class Lexer
    module TokenLexers
      def break?(chunk)
        chunk =~ /\A(終|お)わり\z/
      end

      def tokenize_break(_chunk)
        validate_scope Scope::TYPE_LOOP, ignore: [Scope::TYPE_IF_BLOCK]
        (@stack << Token.new(Token::BREAK)).last
      end
    end
  end
end
