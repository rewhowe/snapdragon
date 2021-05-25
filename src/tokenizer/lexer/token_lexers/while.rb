module Tokenizer
  class Lexer
    module TokenLexers
      def while?(chunk)
        chunk =~ /\A(限|かぎ)り\z/
      end

      # The WHILE token needs to come first in order to intercept the condition
      # (which may contain function calls) on the processor end.
      def tokenize_while(_chunk)
        try_complete_implicit_eq_comparison
        token = Token.new(Token::WHILE)
        @stack.unshift token
        token
      end
    end
  end
end
