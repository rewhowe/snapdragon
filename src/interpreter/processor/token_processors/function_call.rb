module Interpreter
  class Processor
    module TokenProcessors
      def process_function_call(token, options = nil)
        function_key, parameter_particles = function_indentifiers_from_stack token

        Util::Logger.debug(Util::Options::DEBUG_2) do
          stack = @stack.dup
          parameter_list = resolve_parameters_from_stack!.zip(parameter_particles).flatten.join
          @stack = stack
          Util::I18n.t('interpreter.func_call', parameter_list, token.content).lpink
        end

        options = function_options! options

        if token.sub_type == Token::FUNC_BUILT_IN
          delegate_built_in token.content, @stack, options
        else
          function = @current_scope.get_function function_key
          raise Errors::FunctionDoesNotExist, token.content unless function

          resolved_parameters = resolve_parameters_from_stack!
          set_function_parameters function, resolved_parameters
          process_function_body function, options
        end
      end

      private

      def function_options!(options)
        return options if options
        {
          suppress_error?: !next_token_if(Token::BANG).nil?,
          cast_to_boolean?: !next_token_if(Token::QUESTION).nil?,
        }
      end

      def set_function_parameters(function, resolved_parameters)
        function.parameters.zip(resolved_parameters).each do |name, argument|
          function.set_variable name, copy_special(argument)
        end
      end

      def process_function_body(function, options = { suppress_error?: false, cast_to_boolean?: false })
        with_scope function do
          begin
            @sore = process.value # process function tokens
          rescue Errors::BaseError => e
            raise e unless options[:suppress_error?]
            @sore = nil
          end
        end

        @sore = boolean_cast @sore if options[:cast_to_boolean?]
      end
    end
  end
end
