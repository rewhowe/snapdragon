module Interpreter
  class Processor
    module TokenProcessors
      BINARY_COMPARISON_OPERATORS = {
        Token::COMP_LT   => :'<',
        Token::COMP_LTEQ => :'<=',
        Token::COMP_EQ   => :'==',
        Token::COMP_NEQ  => :'!=',
        Token::COMP_GTEQ => :'>=',
        Token::COMP_GT   => :'>',
      }.freeze

      def process_if(_token)
        loop do
          comparison_result = process_if_condition

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

      private

      def process_if_condition
        comparison_tokens = next_tokens_until Token::SCOPE_BEGIN, inclusive?: false

        # TODO: (feature/multiple-condition-branch) Split by AND and OR and do below for each block
        # TODO: (feature/multiple-condition-branch) Should consider short-circuiting too
        comparator_token = comparison_tokens.shift

        # need to check index because the last token could be either FUNCTION_CALL or BANG
        function_call_token_index = comparison_tokens.index { |t| t.type == Token::FUNCTION_CALL }

        if function_call_token_index
          process_if_condition_function_call comparison_tokens, comparator_token
        elsif [Token::COMP_EMP, Token::COMP_NEMP].include? comparator_token.type
          process_empty_comparison comparison_tokens, comparator_token
        elsif [Token::COMP_IN, Token::COMP_NIN].include? comparator_token.type
          process_if_condition_inside comparison_tokens, comparator_token
        else
          # comparison between two values
          value1 = resolve_variable! comparison_tokens
          value2 = resolve_variable! comparison_tokens
          value2 = boolean_cast value2 if comparison_tokens.last&.type == Token::QUESTION

          process_if_comparison value1, value2, comparator_token
        end
      end

      def process_if_condition_function_call(comparison_tokens, comparator_token)
        function_call_token_index = comparison_tokens.index { |t| t.type == Token::FUNCTION_CALL }
        function_call_token = comparison_tokens.slice! function_call_token_index
        @stack = comparison_tokens

        is_loud = comparison_tokens.last&.type == Token::BANG
        comparison_tokens.pop if is_loud

        process_function_call function_call_token, allow_error?: is_loud, cast_to_boolean?: true

        comparison_result = comparator_token.type == Token::COMP_EQ ? @sore : !@sore
        Util::Logger.debug Util::Options::DEBUG_2, "if function call (#{comparison_result})".lpink
        comparison_result
      end

      def process_empty_comparison(comparison_tokens, comparator_token)
        value = resolve_variable! comparison_tokens

        if [String, SdArray].include? value.class
          comparison_result = comparator_token.type == Token::COMP_EMP ? value.length.zero? : value.length.positive?
          Util::Logger.debug Util::Options::DEBUG_2, "if #{value} #{comparator_token} (#{comparison_result})".lpink
        else
          comparison_result = false
          Util::Logger.debug Util::Options::DEBUG_2, 'if empty (false: invalid type)'.lpink
        end

        comparison_result
      end

      def process_if_condition_inside(comparison_tokens, comparator_token)
        value = resolve_variable! comparison_tokens
        container = resolve_variable! comparison_tokens

        if [String, SdArray].include? container.class
          values = container.is_a?(SdArray) ? container.values : container
          condition_result = values.include? value
          condition_result = !condition_result if comparator_token.type == Token::COMP_NIN
          Util::Logger.debug(
            Util::Options::DEBUG_2,
            "if #{value} #{comparator_token} #{values} (#{condition_result})".lpink
          )
        else
          condition_result = false
          Util::Logger.debug Util::Options::DEBUG_2, 'if inside (false: invalid type)'.lpink
        end

        condition_result
      end

      def process_if_comparison(value1, value2, comparator_token)
        unless value1.class == value2.class || (value1.is_a?(Numeric) && value2.is_a?(Numeric))
          Util::Logger.debug Util::Options::DEBUG_2, "if #{value1} ... #{value2} (false: type mismatch)".lpink
          return comparator_token.type == Token::COMP_NEQ
        end

        comparator = BINARY_COMPARISON_OPERATORS[comparator_token.type]

        comparison_result = value1.respond_to?(comparator) && [value1, value2].reduce(comparator)
        Util::Logger.debug Util::Options::DEBUG_2, "if #{value1} #{comparator} #{value2} (#{comparison_result})".lpink
        comparison_result
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
