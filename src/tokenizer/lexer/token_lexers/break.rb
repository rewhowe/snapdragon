module Tokenizer
  class Lexer
    module TokenLexers
      def break?(chunk)
        chunk =~ /^(終|お)わり$/
      end

      def tokenize_break(_chunk)
        validate_scope Scope::TYPE_LOOP, ignore: [Scope::TYPE_IF_BLOCK]
        (@stack << Token.new(Token::BREAK)).last
      end
    end
  end
end
