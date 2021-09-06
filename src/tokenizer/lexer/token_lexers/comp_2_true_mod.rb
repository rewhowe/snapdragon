module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_true_mod?(chunk)
        chunk == '真の'
      end

      def tokenize_comp_2_true_mod(_chunk)
        comparison_tokens = [Token.new(Token::COMP_EQ), Token.new(Token::RVALUE, ID_TRUE, sub_type: Token::VAL_TRUE)]
        @stack.insert last_condition_index_from_stack, *comparison_tokens
        Token.new Token::COMP_2 # for flavour
      end
    end
  end
end
