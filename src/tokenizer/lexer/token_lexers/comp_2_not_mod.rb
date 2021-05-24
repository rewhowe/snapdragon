module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_not_mod?(chunk)
        chunk =~ /\A(で|じゃ)?ない\z/
      end

      def tokenize_comp_2_not_mod(chunk)
        tokenize_comp_2_mod chunk, reverse?: true
      end
    end
  end
end
