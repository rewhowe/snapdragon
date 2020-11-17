module Tokenizer
  class Lexer
    module TokenLexers
      # Either an rvalue (primitive or variable) or its an property token. It
      # cannot be a key variable (otherwise rvalue? would be true).
      def comp_2?(chunk)
        rvalue?(chunk) || property_type(chunk, validate?: false) != Token::KEY_VAR
      end

      def tokenize_comp_2(chunk)
        @stack << comp_token(chunk)
        Token.new Token::COMP_2
      end
    end
  end
end
