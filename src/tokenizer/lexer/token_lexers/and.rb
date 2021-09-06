module Tokenizer
  class Lexer
    module TokenLexers
      def and?(chunk)
        chunk =~ /\A[且か]つ\z/
      end

      def tokenize_and(_chunk)
        try_complete_implicit_eq_comparison
        (@stack << Token.new(Token::AND)).last
      end
    end
  end
end
