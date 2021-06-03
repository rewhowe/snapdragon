module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_false_mod?(chunk)
        chunk == '偽の'
      end

      def tokenize_comp_2_false_mod(_chunk)
        comparison_tokens = [Token.new(Token::COMP_EQ), Token.new(Token::RVALUE, '偽', sub_type: Token::VAL_FALSE)]
        @stack.insert last_condition_index_from_stack, *comparison_tokens
        Token.new Token::COMP_2 # for flavour
      end
    end
  end
end
