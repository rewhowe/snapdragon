module Interpreter
  class Processor
    ##
    # In this file, 'conditional_tokens' refers to an array of tokens. ex:
    # [COMP_EQ, RVALUE, RVALUE, OR, COMP_EQ, RVALUE, RVALUE]
    # 'conditions' refers to an array of 'conditional tokens'. ex:
    # [ [COMP_EQ, RVALUE, RVALUE], [COMP_EQ, RVALUE, RVALUE] ]
    module Conditionals
      BINARY_COMPARISON_OPERATORS = {
        Token::COMP_LT   => :'<',
        Token::COMP_LTEQ => :'<=',
        Token::COMP_EQ   => :'==',
        Token::COMP_NEQ  => :'!=',
        Token::COMP_GTEQ => :'>=',
        Token::COMP_GT   => :'>',
      }.freeze

      def next_conditional_tokens
        conditional_tokens = next_tokens_until Token::SCOPE_BEGIN, inclusive?: false
        conditional_tokens.reject { |t| t.type == Token::COMMA }
      end

      ##
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
      def process_conditional_tokens(conditional_tokens)
        or_conditions = split_conditions conditional_tokens, Token::OR
        process_or_conditions or_conditions
      end

      ##
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

      ##
      # Short-circuits if any condition is true.
      def process_or_conditions(conditions)
        conditions.each_with_index do |conditional_tokens, or_i|
          is_last_or_iteration = or_i == conditions.size - 1

          and_conditions = split_conditions conditional_tokens, Token::AND

          if process_and_conditions and_conditions
            unless is_last_or_iteration
              Util::Logger.debug(Util::Options::DEBUG_2) { Util::I18n.t('interpreter.conditional.or_sc').lpink }
            end
            return true
          end

          unless is_last_or_iteration
            Util::Logger.debug(Util::Options::DEBUG_2) { Util::I18n.t('interpreter.conditional.or').lpink }
          end
        end

        false
      end

      ##
      # Short-circuits if any condition is false.
      def process_and_conditions(conditions)
        conditions.each_with_index do |conditional_tokens, and_i|
          is_last_and_iteration = and_i == conditions.size - 1

          unless process_condition conditional_tokens
            unless is_last_and_iteration
              Util::Logger.debug(Util::Options::DEBUG_2) { Util::I18n.t('interpreter.conditional.and_sc').lpink }
            end
            return false
          end

          unless is_last_and_iteration
            Util::Logger.debug(Util::Options::DEBUG_2) {  Util::I18n.t('interpreter.conditional.and').lpink }
          end
        end

        true
      end

      def process_condition(conditional_tokens)
        comparator_token = conditional_tokens.shift

        # need to check index because the last token could be either FUNCTION_CALL or BANG
        function_call_token_index = conditional_tokens.index { |t| t.type == Token::FUNCTION_CALL }

        if function_call_token_index
          process_condition_function_call conditional_tokens, comparator_token
        elsif [Token::COMP_EMP, Token::COMP_NEMP].include? comparator_token.type
          process_condition_empty conditional_tokens, comparator_token
        elsif [Token::COMP_IN, Token::COMP_NIN].include? comparator_token.type
          process_condition_inside conditional_tokens, comparator_token
        else
          # comparison between two values
          value1 = resolve_variable! conditional_tokens
          value2 = resolve_variable! conditional_tokens
          value2 = boolean_cast value2 if conditional_tokens.last&.type == Token::QUESTION

          process_condition_comparison value1, value2, comparator_token
        end
      end

      def process_condition_function_call(comparison_tokens, comparator_token)
        function_call_token_index = comparison_tokens.index { |t| t.type == Token::FUNCTION_CALL }
        function_call_token = comparison_tokens.slice! function_call_token_index
        @stack = comparison_tokens

        is_loud = comparison_tokens.last&.type == Token::BANG
        comparison_tokens.pop if is_loud

        process_function_call function_call_token, suppress_error?: is_loud, cast_to_boolean?: false

        comparison_result = boolean_cast comparator_token.type == Token::COMP_EQ ? @sore : !@sore
        Util::Logger.debug(Util::Options::DEBUG_2) do
          Util::I18n.t('interpreter.conditional.func_call', comparison_result).lpink
        end
        comparison_result
      end

      def process_condition_empty(comparison_tokens, comparator_token)
        value = resolve_variable! comparison_tokens

        if [String, SdArray].include? value.class
          comparison_result = comparator_token.type == Token::COMP_EMP ? value.length.zero? : value.length.positive?
          Util::Logger.debug(Util::Options::DEBUG_2) { "#{value} #{comparator_token} ? (#{comparison_result})".lpink }
        else
          comparison_result = false
          Util::Logger.debug(Util::Options::DEBUG_2) { Util::I18n.t('interpreter.conditional.empty_false').lpink }
        end

        comparison_result
      end

      def process_condition_inside(comparison_tokens, comparator_token)
        value = resolve_variable! comparison_tokens
        container = resolve_variable! comparison_tokens

        if container.is_a?(SdArray) || (container.is_a?(String) && value.is_a?(String))
          values = container.is_a?(SdArray) ? container.values : container
          condition_result = values.include? value
          condition_result = !condition_result if comparator_token.type == Token::COMP_NIN
          Util::Logger.debug(Util::Options::DEBUG_2) do
            "#{value} #{comparator_token} #{values} ? (#{condition_result})".lpink
          end
        else
          condition_result = false
          Util::Logger.debug(Util::Options::DEBUG_2) { Util::I18n.t('interpreter.conditional.inside_false').lpink }
        end

        condition_result
      end

      def process_condition_comparison(value1, value2, comparator_token)
        unless value1.class == value2.class || (value1.is_a?(Numeric) && value2.is_a?(Numeric))
          Util::Logger.debug(Util::Options::DEBUG_2) do
            Util::I18n.t('interpreter.conditional.comp_false', value1, value2).lpink
          end
          return comparator_token.type == Token::COMP_NEQ
        end

        comparator = BINARY_COMPARISON_OPERATORS[comparator_token.type]

        comparison_result = value1.respond_to?(comparator) && [value1, value2].reduce(comparator)
        Util::Logger.debug(Util::Options::DEBUG_2) do
          "#{value1} #{comparator} #{value2} ? (#{comparison_result})".lpink
        end
        comparison_result
      end
    end
  end
end
