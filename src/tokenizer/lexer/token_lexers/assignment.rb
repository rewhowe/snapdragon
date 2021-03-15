module Tokenizer
  class Lexer
    module TokenLexers
      def assignment?(chunk)
        chunk =~ /.+は\z/
      end

      def tokenize_assignment(chunk)
        name = chunk.chomp 'は'
        if @context.last_token_type == Token::POSSESSIVE
          sub_type = property_type name
          property_token = Token.new Token::ASSIGNMENT, Oracles::Property.sanitize(name), sub_type: sub_type
          validate_property_assignment property_token, @stack.last
          (@stack << property_token).last
        else
          validate_variable_name name
          (@stack << Token.new(Token::ASSIGNMENT, name, sub_type: variable_type(name, validate?: false))).last
        end
      end
    end
  end
end
