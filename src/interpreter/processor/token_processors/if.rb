module Interpreter
  class Processor
    module TokenProcessors
      def process_if(_token)
        loop do
          comparator_token = next_token

          comparison_result = process_if_condition comparator_token

          body_tokens = next_tokens_from_scope_body

          if comparison_result
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

      def process_if_condition(comparator_token)
        comparison_tokens = next_tokens_until Token::SCOPE_BEGIN, inclusive?: false

        function_call_token_index = comparison_tokens.index { |t| t.type == Token::FUNCTION_CALL }
        if function_call_token_index
          process_if_condition_function_call comparison_tokens, function_call_token_index
          comparison_result = comparator_token.type == Token::COMP_EQ ? @sore : !@sore

          Util::Logger.debug Util::Options::DEBUG_2, "if function call (#{comparison_result})".lpink
        else
          value1 = resolve_variable! comparison_tokens
          value2 = resolve_variable! comparison_tokens
          value2 = boolean_cast value2 if comparison_tokens.last&.type == Token::QUESTION

          comparator = {
            Token::COMP_LT   => :'<',
            Token::COMP_LTEQ => :'<=',
            Token::COMP_EQ   => :'==',
            Token::COMP_NEQ  => :'!=',
            Token::COMP_GTEQ => :'>=',
            Token::COMP_GT   => :'>',
          }[comparator_token.type]

          comparison_result = [value1, value2].reduce comparator

          Util::Logger.debug Util::Options::DEBUG_2, "if #{value1} #{comparator} #{value2} (#{comparison_result})".lpink
        end

        comparison_result
      end

      def process_if_condition_function_call(comparison_tokens, function_call_token_index)
        function_call_token = comparison_tokens.slice! function_call_token_index
        @stack = comparison_tokens

        is_loud = comparison_tokens.last&.type == Token::BANG
        comparison_tokens.pop if is_loud

        process_function_call function_call_token, allow_error?: is_loud, cast_to_boolean?: true
      end

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
