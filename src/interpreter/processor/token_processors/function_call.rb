module Interpreter
  class Processor
    module TokenProcessors
      def process_function_call(token, options = nil)
        function_key, parameter_particles = function_indentifiers_from_stack token

        arguments = @stack.dup
        resolved_arguments = resolve_function_arguments_from_stack!

        Util::Logger.debug(
          Util::Options::DEBUG_2,
          "call #{resolved_arguments.zip(parameter_particles).flatten.join}#{token.content}".lpink
        )

        options = function_options! options

        if token.sub_type == Token::FUNC_BUILT_IN
          delegate_built_in token.content, arguments, options
        else
          function = @current_scope.get_function function_key
          raise Errors::FunctionDoesNotExist, token.content unless function
          set_function_parameters function, resolved_arguments
          process_function_body function, options
        end
      end

      private

      def resolve_function_arguments_from_stack!
        [].tap { |a| a << resolve_variable!(@stack) until @stack.empty? }
      end

      def function_options!(options)
        return options if options
        {
          suppress_error?: !next_token_if(Token::BANG).nil?,
          cast_to_boolean?: !next_token_if(Token::QUESTION).nil?,
        }
      end

      def set_function_parameters(function, resolved_arguments)
        function.parameters.zip(resolved_arguments).each do |name, argument|
          function.set_variable name, argument
        end
      end

      def process_function_body(function, options = { suppress_error?: false, cast_to_boolean?: false })
        current_scope = @current_scope # save current scope
        @current_scope = function      # swap current scope with function

        begin
          @sore = process.value        # process function tokens
        rescue Errors::BaseError => e
          raise e unless options[:suppress_error?]
          @sore = nil
        end
        @sore = boolean_cast @sore if options[:cast_to_boolean?]

        @current_scope = current_scope # replace current scope
      end
    end
  end
end
