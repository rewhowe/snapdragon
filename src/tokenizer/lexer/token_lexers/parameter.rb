module Tokenizer
  class Lexer
    module TokenLexers
      def parameter?(chunk)
        chunk =~ /.+#{PARTICLE}$/ && !begin
          next_chunk = @reader.peek_next_chunk
          punctuation?(next_chunk) || comp_3_eq?(next_chunk) || comp_3_neq?(next_chunk)
        end
      end

      def process_parameter(chunk)
        particle = chunk.match(/(#{PARTICLE})$/)[1]
        variable = sanitize_variable chunk.chomp! particle

        if !@stack.empty? && @stack.last.type == Token::PROPERTY
          property_token = @stack.last
          parameter_sub_type = attribute_type variable
        else
          parameter_sub_type = variable_type variable, validate?: false # function def parameters may not exist
        end

        parameter_token = Token.new Token::PARAMETER, variable, particle: particle, sub_type: parameter_sub_type

        # NOTE: Untested (redundant check)
        validate_property_and_attribute property_token, parameter_token if property_token

        (@stack << parameter_token).last
      end
    end
  end
end
