module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_nbe?(chunk)
        chunk == 'なければ'
      end

      def tokenize_comp_2_nbe(chunk)
        tokenize_comp_2_be chunk, reverse?: true
      end
    end
  end
end
