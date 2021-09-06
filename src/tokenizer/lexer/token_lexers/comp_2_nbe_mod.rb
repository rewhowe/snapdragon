module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_nbe_mod?(chunk)
        chunk == 'ない'
      end

      def tokenize_comp_2_nbe_mod(chunk)
        tokenize_comp_2_be_mod chunk, reverse?: true
      end
    end
  end
end
