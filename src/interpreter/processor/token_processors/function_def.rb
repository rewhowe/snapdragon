module Interpreter
  class Processor
    module TokenProcessors
      def process_function_def(token)
        function_key, parameter_particles = function_indentifiers_from_stack token

        # skip if already defined
        unless @current_scope.get_function function_key, bubble_up?: false
          body_tokens = next_tokens_from_scope_body
          parameters = @stack.map(&:content)
          @current_scope.define_function function_key, body_tokens, parameters

          Util::Logger.debug Util::Options::DEBUG_2, "define #{token.content} (#{parameter_particles.join ','})".lpink
        end

        @stack.clear
      end
    end
  end
end
