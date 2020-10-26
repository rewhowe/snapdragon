module Tokenizer
  class Lexer
    module TokenLexers
      # Either an rvalue (primitive or variable) or its an attribute token. It
      # cannot be a key variable (otherwise rvalue? would be true).
      def comp_2?(chunk)
        (rvalue?(chunk) || attribute_type(chunk, validate?: false) != Token::KEY_VAR) &&
          question?(@reader.peek_next_chunk)
      end

      def process_comp_2(chunk)
        @stack << comp_token(chunk)
        Token.new Token::COMP_2
      end
    end
  end
end
