module Interpreter
  class Processor
    module TokenProcessors
      # Very similar to loop, but operates on a condition instead.
      def process_while(_token)
        conditional_tokens = next_conditional_tokens
        conditional_tokens.pop # discard loop

        body_tokens = next_tokens_from_scope_body

        current_scope = @current_scope                                           # save current scope
        @current_scope = Scope.new @current_scope, Scope::TYPE_LOOP, body_tokens # swap current scope with loop scope

        result = nil
        loop do
          break unless process_conditional_tokens conditional_tokens

          @current_scope.reset
          result = process
          if result.is_a? ReturnValue
            next if result.value == Token::NEXT
            break
          end
        end

        @current_scope = current_scope # replace current scope

        result if result.is_a?(ReturnValue) && result.value != Token::BREAK
      end
    end
  end
end
