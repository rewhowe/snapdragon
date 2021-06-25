module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2?(chunk)
        chunk =~ /\A(ならば?|であれば)\z/
      end

      def tokenize_comp_2(chunk, options = { reverse?: false })
        comparison_tokens = comp_2_comparison_tokens

        raise Errors::UnexpectedInput, chunk if comparison_tokens.nil?

        if @context.last_token_type == Token::QUESTION
          if last_segment_from_stack.find { |t| t.type == Token::FUNCTION_CALL }
            @stack.pop # drop question
          else # truthy check
            comparison_tokens << Token.new(Token::RVALUE, ID_TRUE, sub_type: Token::VAL_TRUE)
          end
        end

        flip_comparison comparison_tokens if options[:reverse?]
        close_if_statement comparison_tokens
      end
    end
  end
end
