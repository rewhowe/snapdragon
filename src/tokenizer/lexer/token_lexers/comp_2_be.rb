module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_be?(chunk)
        chunk == 'あれば'
      end

      def tokenize_comp_2_be(chunk, options = { reverse?: false })
        comparison_tokens = comp_2_be_comparison_tokens! chunk
        flip_comparison comparison_tokens if options[:reverse?]
        close_if_statement comparison_tokens
      end
    end
  end
end
