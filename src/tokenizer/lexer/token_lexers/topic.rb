module Tokenizer
  class Lexer
    module TokenLexers
      def topic?(chunk)
        chunk =~ /.+は\z/
      end

      ##
      # Presently only used for assignment.
      def tokenize_topic(chunk)
        name = chunk.chomp 'は'
        if @context.last_token_type == Token::POSSESSIVE
          sub_type = property_type name
          property_token = Token.new Token::ASSIGNMENT, Oracles::Property.sanitize(name), sub_type: sub_type
          validate_property_assignment property_token, @stack.last
          @stack << property_token
        else
          validate_variable_name name
          @stack << Token.new(Token::ASSIGNMENT, name, sub_type: variable_type(name, validate?: false))
        end
        Token.new Token::TOPIC
      end
    end
  end
end
