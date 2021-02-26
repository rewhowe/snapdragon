module Tokenizer
  class Lexer
    module TokenLexers
      def assignment?(chunk)
        chunk =~ /.+は\z/
      end

      # TODO: (v1.1.0) Set sub type for associative arrays (KEY_INDEX, KEY_NAME, KEY_VARIABLE).
      # TODO: (v1.1.0) Raise an error when assigning to a read-only property.
      # Currently only variables can be assigned to.
      def tokenize_assignment(chunk)
        name = chunk.chomp 'は'
        if @context.last_token_type == Token::POSSESSIVE
          sub_type = property_type name
          property_token = Token.new Token::ASSIGNMENT, Oracles::Property.sanitize(name), sub_type: sub_type
          validate_property_and_owner property_token, @stack.last
          raise Errors::AssignmentToReadOnlyProperty, name if Oracles::Property.read_only? sub_type
          (@stack << property_token).last
        else
          validate_variable_name name
          (@stack << Token.new(Token::ASSIGNMENT, name, sub_type: variable_type(name, validate?: false))).last
        end
      end
    end
  end
end
