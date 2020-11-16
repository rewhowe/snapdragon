module Tokenizer
  class Lexer
    module TokenLexers
      # Either a valid attribute or KEY_VAR with an existing variable.
      def attribute?(chunk)
        Oracles::Attribute.type(chunk) != Token::KEY_VAR || variable?(chunk)
      end

      # TODO: (v1.1.0) Cannot assign keys / indices to themselves. (Fix at same time as tokenize_rvalue)
      def tokenize_attribute(chunk)
        chunk = sanitize_variable chunk
        attribute_sub_type = attribute_type chunk

        attribute_token = Token.new Token::ATTRIBUTE, chunk, sub_type: attribute_sub_type

        property_token = @stack.last
        validate_property_and_attribute property_token, attribute_token

        (@stack << attribute_token).last
      end
    end
  end
end
