module Tokenizer
  class Lexer
    module TokenLexers
      def or?(chunk)
        chunk =~ /\A(又|また)は\z/
      end

      def tokenize_or(_chunk)
        try_complete_implicit_eq_comparison
        (@stack << Token.new(Token::OR)).last
      end
    end
  end
end
