module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_nbe_conj?(chunk)
        chunk == 'なく'
      end

      def tokenize_comp_2_nbe_conj(chunk)
        tokenize_comp_2_be_conj chunk, reverse?: true
      end
    end
  end
end
