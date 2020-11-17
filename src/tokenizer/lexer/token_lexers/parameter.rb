module Tokenizer
  class Lexer
    module TokenLexers
      def parameter?(chunk)
        chunk =~ /.+#{PARTICLE}$/
      end

      def tokenize_parameter(chunk)
        particle = chunk.match(/(#{PARTICLE})$/)[1]
        variable = Oracles::Value.sanitize chunk.chomp particle

        if @context.last_token_type == Token::POSSESSIVE
          property_owner_token = @stack.last
          parameter_sub_type = property_type variable
        else
          parameter_sub_type = variable_type variable, validate?: false # function def parameters may not exist
        end

        parameter_token = Token.new Token::PARAMETER, variable, particle: particle, sub_type: parameter_sub_type

        # NOTE: Untested (redundant check)
        validate_property_and_owner property_owner_token, parameter_token if property_owner_token

        (@stack << parameter_token).last
      end
    end
  end
end
