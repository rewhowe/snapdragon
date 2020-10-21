module Tokenizer
  class Lexer
    module TokenProcessors
      def loop?(chunk)
        chunk =~ /^((繰|く)り(返|かえ)す)$/
      end

      # If stack size is 2: the loop parameters are the start and end values.
      # If stack size is 3: one parameter is a value and the other is a property.
      # If stack size is 4: the loop parameters are the start and end values, as properties.
      def process_loop(_chunk)
        if [2, 3, 4].include? @stack.size
          (start_parameter, start_property) = loop_parameter_from_stack 'から'
          (end_parameter, end_property)     = loop_parameter_from_stack 'まで'

          unless @stack.empty?
            invalid_particle_token = @stack.find { |t| t.particle && !%w[から まで].include?(t.particle) }
            raise Errors::InvalidLoopParameterParticle, invalid_particle_token.particle if invalid_particle_token
            raise Errors::UnexpectedLoop
          end

          validate_loop_parameters start_parameter, start_property
          validate_loop_parameters end_parameter, end_property

          @tokens += [start_property, start_parameter, end_property, end_parameter].compact
        elsif !@stack.empty?
          raise Errors::UnexpectedLoop
        end

        token = Token.new Token::LOOP
        @tokens << token
        begin_scope Scope::TYPE_LOOP
        token
      end
    end
  end
end
