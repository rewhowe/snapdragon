module Interpreter
  class Processor
    module Validators
      def validate_type(valid_types, value)
        return if valid_types.any? { |type| value.is_a? type }
        expectation = valid_types.map do |type|
          {
            Numeric => '数値',
            String  => '文字列',
            SdArray => '配列',
          }[type] || type.to_s # Just in case
        end
        raise Errors::InvalidType.new expectation.join(' or '), Formatter.output(value)
      end

      def validate_interpolation_tokens(interpolation_tokens)
        substitute_token = interpolation_tokens[0]
        if substitute_token.sub_type == Token::VARIABLE && !@current_scope.variable?(substitute_token.content)
          raise Errors::VariableDoesNotExist, substitute_token.content
        end

        property_token = interpolation_tokens[1]
        return if property_token&.sub_type != Token::KEY_VAR || @current_scope.variable?(property_token.content)
        raise Errors::PropertyDoesNotExist, property_token.content
      end

      def valid_string_index?(string, index)
        return false unless (index.is_a?(String) && index.numeric?) || index.is_a?(Numeric)
        int_index = index.to_i
        int_index >= 0 && int_index < string.length && int_index.to_f == index.to_f
      end
    end
  end
end
