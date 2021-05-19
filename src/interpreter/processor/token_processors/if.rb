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
          condition_result = process_if_condition

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

      # Read in the entire conditional expression and remove commas.
      # Break up the expression by OR operators, then loop over each expression.
      # Break up each OR expression by AND operators, then evaluate each side.
      # Because each condition around AND operators are evaluated, it causes
      # AND to have a higher precedence than OR.
      #
      # a AND b OR c AND d OR e   * break up the expression by OR operators
      #         /\         /\
      # a AND b    c AND d    e   * break up each OR expression by AND operators
      #   / \        / \
      # a     b    c     d        * evaluate each AND expression
      #
      # * Evaluate a, short-ciruit AND if false
      # * Evaluate b, short-circuit OR if true
      # * Evaluate c, short-circuit AND if true
      # * Evaluate d, short-circuit OR if true
      # * Evaluate e
      def process_if_condition
        conditional_tokens = next_tokens_until Token::SCOPE_BEGIN, inclusive?: false
        conditional_tokens.reject! { |t| t.type == Token::COMMA }

        or_conditions = split_conditions conditional_tokens, Token::OR
        process_if_or_conditions or_conditions
      end

      # Split a list of tokens into a list of lists of tokens, using
      # split_token_type as the delimiter. The delimiter is not included.
      def split_conditions(conditional_tokens, split_token_type)
        [].tap do |conditions|
          condition = []
          conditional_tokens.each do |token|
            if token.type == split_token_type
              conditions << condition
              condition = []
            else
              condition << token
            end
          end
          conditions << condition
        end
      end

      # Short-circuits if any condition is true.
      def process_if_or_conditions(conditions)
        conditions.each_with_index do |conditional_tokens, or_i|
          is_last_or_iteration = or_i == conditions.size - 1

          and_conditions = split_conditions conditional_tokens, Token::AND

          if process_if_and_conditions and_conditions
            Util::Logger.debug Util::Options::DEBUG_2, 'OR (short-circuit)'.lpink unless is_last_or_iteration
            return true
          end

          Util::Logger.debug Util::Options::DEBUG_2, 'OR'.lpink unless is_last_or_iteration
        end

        false
      end

      # Short-circuits if any condition is false.
      def process_if_and_conditions(conditions)
        conditions.each_with_index do |conditional_tokens, and_i|
          is_last_and_iteration = and_i == conditions.size - 1

          unless evaluate_condition conditional_tokens
            Util::Logger.debug Util::Options::DEBUG_2, 'AND (short-circuit)'.lpink unless is_last_and_iteration
            return false
          end

          Util::Logger.debug Util::Options::DEBUG_2, 'AND'.lpink unless is_last_and_iteration
        end

        true
      end

      def evaluate_condition(conditional_tokens)
        comparator_token = conditional_tokens.shift

        # need to check index because the last token could be either FUNCTION_CALL or BANG
        function_call_token_index = conditional_tokens.index { |t| t.type == Token::FUNCTION_CALL }

        if function_call_token_index
          evaluate_condition_function_call conditional_tokens, comparator_token
        elsif [Token::COMP_EMP, Token::COMP_NEMP].include? comparator_token.type
          evaluate_condition_empty conditional_tokens, comparator_token
        elsif [Token::COMP_IN, Token::COMP_NIN].include? comparator_token.type
          evaluate_condition_inside conditional_tokens, comparator_token
        else
          # comparison between two values
          value1 = resolve_variable! conditional_tokens
          value2 = resolve_variable! conditional_tokens
          value2 = boolean_cast value2 if conditional_tokens.last&.type == Token::QUESTION

          evaluate_condition_comparison value1, value2, comparator_token
        end
      end

      def evaluate_condition_function_call(comparison_tokens, comparator_token)
        function_call_token_index = comparison_tokens.index { |t| t.type == Token::FUNCTION_CALL }
        function_call_token = comparison_tokens.slice! function_call_token_index
        @stack = comparison_tokens

        is_loud = comparison_tokens.last&.type == Token::BANG
        comparison_tokens.pop if is_loud

        process_function_call function_call_token, suppress_error?: is_loud, cast_to_boolean?: false

        comparison_result = boolean_cast comparator_token.type == Token::COMP_EQ ? @sore : !@sore
        Util::Logger.debug Util::Options::DEBUG_2, "if function call (#{comparison_result})".lpink
        comparison_result
      end

      def evaluate_condition_empty(comparison_tokens, comparator_token)
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

      def evaluate_condition_inside(comparison_tokens, comparator_token)
        value = resolve_variable! comparison_tokens
        container = resolve_variable! comparison_tokens

        if container.is_a?(SdArray) || (container.is_a?(String) && value.is_a?(String))
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

      def evaluate_condition_comparison(value1, value2, comparator_token)
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
