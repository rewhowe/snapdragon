module Tokenizer
  class Lexer
    module TokenProcessors
      def next?(chunk)
        chunk =~ /^(次|つぎ)$/
      end

      def process_next(_chunk)
        validate_scope Scope::TYPE_LOOP, ignore: [Scope::TYPE_IF_BLOCK]
        (@tokens << Token.new(Token::NEXT)).last
      end
    end
  end
end
