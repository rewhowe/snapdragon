module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_be_conj?(chunk)
        chunk == 'あり'
      end

      def tokenize_comp_2_be_conj(chunk, options = { reverse?: false })
        comparison_tokens = comp_2_be_comparison_tokens! chunk
        flip_comparison comparison_tokens if options[:reverse?]
        @stack.insert last_condition_index_from_stack, *comparison_tokens
      end
    end
  end
end
