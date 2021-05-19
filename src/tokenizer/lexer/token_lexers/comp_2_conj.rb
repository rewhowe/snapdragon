module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_conj?(chunk)
        chunk =~ /\Aで(あり)?\z/
      end

      def tokenize_comp_2_conj(chunk, options = { reverse?: false })
        comparison_tokens = comp_2_comparison_tokens

        raise Errors::UnexpectedInput, chunk if comparison_tokens.nil?

        if @context.last_token_type == Token::QUESTION
          if last_segment_from_stack.find { |t| t.type == Token::FUNCTION_CALL }
            @stack.pop # drop question
          else # truthy check
            comparison_tokens << Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE)
          end
        end

        flip_comparison comparison_tokens if options[:reverse?]
        @stack.insert last_condition_index_from_stack + 1, *comparison_tokens
        Token.new Token::COMP_2_CONJ # for flavour
      end
    end
  end
end
