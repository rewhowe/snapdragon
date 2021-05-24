module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_be_mod?(chunk)
        chunk == 'ある'
      end

      ##
      # Despite the generic naming, this token presently only follows COMP_1_IN.
      def tokenize_comp_2_be_mod(_chunk)
        @stack.insert last_condition_index_from_stack, Token.new(Token::COMP_IN)
      end
    end
  end
end
