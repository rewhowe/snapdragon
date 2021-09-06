module Interpreter
  class Processor
    module TokenProcessors
      def process_try(_token)
        body_tokens = next_tokens_from_scope_body

        error = nil
        result = nil

        with_scope Scope.new(@current_scope, Scope::TYPE_TRY, body_tokens) do
          begin
            result = process
          rescue Errors::BaseError => e
            error = e.message
          end
        end

        @current_scope.set_variable Tokenizer::ID_ERR, error
        result
      end
    end
  end
end
