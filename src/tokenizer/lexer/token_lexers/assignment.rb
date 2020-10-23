module Tokenizer
  class Lexer
    module TokenLexers
      def assignment?(chunk)
        chunk =~ /.+は$/ && !else_if?(chunk)
      end

      # TODO: (v1.1.0) Set sub type for associative arrays (KEY_INDEX, KEY_NAME, KEY_VARIABLE).
      # TODO: (v1.1.0) Raise an error when assigning to a read-only property.
      # Currently only variables can be assigned to.
      def process_assignment(chunk)
        raise Errors::MultipleAssignment, chunk if @context.inside_assignment?
        @context.inside_assignment = true

        name = chunk.chomp 'は'
        validate_variable_name name
        (@stack << Token.new(Token::ASSIGNMENT, name, sub_type: variable_type(name, validate?: false))).last
      end
    end
  end
end
