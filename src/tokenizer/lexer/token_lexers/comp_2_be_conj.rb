module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_be_conj?(chunk)
        chunk == 'あり'
      end

      ##
      # Despite the generic naming, this token presently only follows COMP_1_IN.
      def tokenize_comp_2_be_conj(_chunk)
        @stack.insert last_condition_index_from_stack + 1, Token.new(Token::COMP_IN)
      end
    end
  end
end
