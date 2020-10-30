module Tokenizer
  class Lexer
    module TokenLexers
      def loop?(chunk)
        chunk =~ /^((繰|く)り(返|かえ)す)$/
      end

      # If stack size is 2: the loop parameters are the start and end values.
      # If stack size is 3: one parameter is a value and the other is a property.
      # If stack size is 4: the loop parameters are the start and end values, as properties.
      def process_loop(_chunk)
        unless @stack.empty?
          (start_parameter, start_property) = loop_parameter_from_stack! 'から'
          (end_parameter, end_property)     = loop_parameter_from_stack! 'まで'

          # Skip validation if already validated by LOOP_ITERATOR
          unless @context.last_token_type == Token::LOOP_ITERATOR
            invalid_particle_token = @stack.find { |t| t.particle && !%w[から まで].include?(t.particle) }
            raise Errors::InvalidLoopParameterParticle, invalid_particle_token.particle if invalid_particle_token

            validate_loop_parameters start_parameter, start_property
            validate_loop_parameters end_parameter, end_property
          end

          @stack += [start_property, start_parameter, end_property, end_parameter].compact
        end

        token = Token.new Token::LOOP
        @stack << token
        begin_scope Scope::TYPE_LOOP
        token
      end
    end
  end
end
