module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_not_conj?(chunk)
        chunk =~ /\A(で|じゃ)?なく\z/
      end

      def tokenize_comp_2_not_conj(chunk)
        tokenize_comp_2_conj chunk, reverse?: true
      end
    end
  end
end
