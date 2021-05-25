module Interpreter
  class Processor
    module TokenProcessors
      def process_if(_token)
        loop do
          condition_result = process_conditional_tokens next_conditional_tokens

          body_tokens = next_tokens_from_scope_body

          if condition_result
            result = process_if_body body_tokens

            while [Token::ELSE_IF, Token::ELSE].include? peek_next_token&.type
              next_tokens_until Token::SCOPE_BEGIN # discard condition
              next_tokens_until Token::SCOPE_CLOSE # discard body
            end

            return result
          elsif next_token_if Token::ELSE_IF # consume else_if and perform branch again
            next
          elsif next_token_if Token::ELSE # consume else and execute body
            body_tokens = next_tokens_from_scope_body

            return process_if_body body_tokens
          else
            break
          end
        end
      end

      private

      def process_if_body(body_tokens)
        current_scope = @current_scope                                               # save current scope
        @current_scope = Scope.new @current_scope, Scope::TYPE_IF_BLOCK, body_tokens # swap current scope with if scope

        result = process

        @current_scope = current_scope # replace current scope

        result
      end
    end
  end
end
