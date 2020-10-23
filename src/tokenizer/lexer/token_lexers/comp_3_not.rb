module Tokenizer
  class Lexer
    module TokenLexers
      def comp_3_not?(chunk)
        chunk == 'でなければ'
      end

      def process_comp_3_not(chunk)
        process_comp_3 chunk, reverse?: true
      end
    end
  end
end
