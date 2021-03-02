module Tokenizer
  class Lexer
    module TokenLexers
      # Either an rvalue (primitive or variable) or its a property token. It
      # cannot be a key variable (otherwise rvalue? would be true).
      def comp_1?(chunk)
        # TODO: safe to not check それ・あれ as keys in comp?
        rvalue?(chunk) || property_type(chunk, validate?: false) != Token::KEY_VAR
      end

      def tokenize_comp_1(chunk)
        @stack << comp_token(chunk)
        Token.new Token::COMP_1
      end
    end
  end
end
