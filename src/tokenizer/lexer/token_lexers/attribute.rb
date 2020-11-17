module Tokenizer
  class Lexer
    module TokenLexers
      # Either a valid property or KEY_VAR with an existing variable.
      def property?(chunk)
        Oracles::Property.type(chunk) != Token::KEY_VAR || variable?(chunk)
      end

      # TODO: (v1.1.0) Cannot assign keys / indices to themselves. (Fix at same time as tokenize_rvalue)
      def tokenize_property(chunk)
        chunk = Oracles::Value.sanitize chunk
        property_sub_type = property_type chunk

        property_token = Token.new Token::PROPERTY, chunk, sub_type: property_sub_type

        property_owner_token = @stack.last
        validate_property_and_owner property_owner_token, property_token

        (@stack << property_token).last
      end
    end
  end
end
