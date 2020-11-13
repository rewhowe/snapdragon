module Interpreter
  class Processor
    module TokenProcessors
      def process_function_call(token)
        function_key, parameter_particles = function_indentifiers_from_stack token

        arguments = @stack.dup
        resolved_arguments = resolve_function_arguments_from_stack!

        Util::Logger.debug(
          Util::Options::DEBUG_2,
          "call #{resolved_arguments.zip(parameter_particles).flatten.join}#{token.content}".lpink
        )

        options = {
          allow_error?: !next_token_if(Token::BANG).nil?,
          cast_to_boolean?: !next_token_if(Token::QUESTION).nil?,
        }

        if token.sub_type == Token::FUNC_BUILT_IN
          delegate_built_in token.content, arguments, options
        else
          function = @current_scope.get_function function_key
          set_function_parameters function, resolved_arguments
          process_function_body function, options
        end
      end

      def set_function_parameters(function, resolved_arguments)
        function.parameters.zip(resolved_arguments).each do |name, argument|
          function.set_variable name, argument
        end
      end

      def process_function_body(function, options = { allow_error?: false, cast_to_boolean?: false })
        current_scope = @current_scope # save current scope
        @current_scope = function      # swap current scope with function
        @current_scope.reset           # reset the token pointer
        begin
          @sore = process.value        # process function tokens
          @sore = boolean_cast @sore if options[:cast_to_boolean?]
        rescue Errors::BaseError => e
          raise e if options[:allow_error?]
          @sore = nil
        end
        @current_scope = current_scope # replace current scope
      end
    end
  end
end
