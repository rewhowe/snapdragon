module Tokenizer
  class Lexer
    module TokenLexers
      def assignment?(chunk)
        chunk =~ /.+は$/
      end

      # TODO: (v1.1.0) Set sub type for associative arrays (KEY_INDEX, KEY_NAME, KEY_VARIABLE).
      # TODO: (v1.1.0) Raise an error when assigning to a read-only property.
      # Currently only variables can be assigned to.
      def process_assignment(chunk)
        name = chunk.chomp 'は'
        validate_variable_name name
        (@stack << Token.new(Token::ASSIGNMENT, name, sub_type: variable_type(name, validate?: false))).last
      end
    end
  end
end
