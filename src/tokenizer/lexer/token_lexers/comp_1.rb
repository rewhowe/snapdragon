module Tokenizer
  class Lexer
    module TokenLexers
      # Either an rvalue (primitive or variable) or a property token. It cannot
      # be a key variable (otherwise rvalue? would be true), so if property_type
      # returns KEY_VAR it must not be a valid property.
      def comp_1?(chunk)
        rvalue?(chunk) || property_type(chunk, validate?: false) != Token::KEY_VAR
      end

      def tokenize_comp_1(chunk)
        @stack << comp_token(chunk)
        Token.new Token::COMP_1
      end
    end
  end
end
