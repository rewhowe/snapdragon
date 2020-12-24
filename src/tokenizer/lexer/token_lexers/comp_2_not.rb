module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_not?(chunk)
        chunk =~ /\A(で|じゃ)なければ\z/
      end

      def tokenize_comp_2_not(chunk)
        tokenize_comp_2 chunk, reverse?: true
      end
    end
  end
end
