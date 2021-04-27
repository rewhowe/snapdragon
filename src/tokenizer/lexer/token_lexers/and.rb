module Tokenizer
  class Lexer
    module TokenLexers
      def and?(chunk)
        chunk =~ /\A[且か]つ\z/
      end

      # If the last segment does not contain a comparator, it must be an
      # implicit COMP_EQ check.
      def tokenize_and(_chunk)
        comparator_token = last_segment_from_stack[1]
        valid_comparator_tokens = [
          Token::COMP_LT,
          Token::COMP_LTEQ,
          Token::COMP_EQ,
          Token::COMP_NEQ,
          Token::COMP_GTEQ,
          Token::COMP_GT,
        ]
        unless valid_comparator_tokens.include? comparator_token
          @stack.insert last_condition_index_from_stack + 1, Token.new(Token::COMP_EQ)
        end
        (@stack << Token.new(Token::AND)).last
      end
    end
  end
end
