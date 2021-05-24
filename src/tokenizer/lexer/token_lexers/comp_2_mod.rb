module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_mod?(chunk)
        chunk == 'である'
      end

      def tokenize_comp_2_mod(chunk, options = { reverse?: false })
        comparison_tokens = comp_2_comparison_tokens

        raise Errors::UnexpectedInput, chunk if comparison_tokens.nil?

        if @context.last_token_type == Token::QUESTION
          # drop question
          @stack.pop if last_segment_from_stack.find { |t| t.type == Token::FUNCTION_CALL }
        end

        flip_comparison comparison_tokens if options[:reverse?]
        @stack.insert last_condition_index_from_stack, *comparison_tokens
        Token.new Token::COMP_2 # for flavour
      end
    end
  end
end
