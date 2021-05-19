module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_nbe_conj?(chunk)
        chunk == 'なく'
      end

      ##
      # Despite the generic naming, this token presently only follows COMP_1_IN.
      def tokenize_comp_2_nbe_conj(_chunk)
        @stack.insert last_condition_index_from_stack + 1, Token.new(Token::COMP_NIN)
      end
    end
  end
end
