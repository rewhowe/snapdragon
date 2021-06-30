module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_nbe?(chunk)
        chunk == 'なければ'
      end

      ##
      # Despite the generic naming, this token presently only follows COMP_1_IN.
      def tokenize_comp_2_nbe(chunk)
        tokenize_comp_2_be chunk, reverse?: true
      end
    end
  end
end
