module Tokenizer
  class Lexer
    module TokenProcessors
      def attribute?(chunk)
        is_valid_attribute = @last_token_type == Token::PROPERTY && attribute_type(chunk, validate?: false)
        is_valid_attribute && !@context.inside_if_condition? && begin
          next_chunk = @reader.peek_next_chunk
          eol?(next_chunk) || punctuation?(next_chunk)
        end
      end
      #
      # TODO: (v1.1.0) Cannot assign keys / indices to themselves. (Fix at same time as process_rvalue)
      def process_attribute(chunk)
        chunk = sanitize_variable chunk
        attribute_sub_type = attribute_type chunk

        attribute_token = Token.new Token::ATTRIBUTE, chunk, sub_type: attribute_sub_type

        property_token = @stack.last
        validate_property_and_attribute property_token, attribute_token

        @stack << attribute_token

        try_assignment_close

        attribute_token
      end
    end
  end
end
