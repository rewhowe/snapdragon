module Tokenizer
  class Lexer
    module TokenLexers
      def while?(chunk)
        chunk =~ /\A(限|かぎ)り\z/
      end

      def tokenize_while(_chunk)
        try_complete_implicit_eq_comparison
        token = Token.new(Token::WHILE)
        @stack.unshift token
        token
      end
    end
  end
end
