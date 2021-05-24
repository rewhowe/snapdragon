module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_nbe_mod?(chunk)
        chunk == 'ない'
      end

      ##
      # Despite the generic naming, this token presently only follows COMP_1_IN.
      def tokenize_comp_2_nbe_mod(_chunk)
        @stack.insert last_condition_index_from_stack, Token.new(Token::COMP_NIN)
      end
    end
  end
end
