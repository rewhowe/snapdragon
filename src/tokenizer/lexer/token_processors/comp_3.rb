module Tokenizer
  class Lexer
    module TokenProcessors
      def comp_3?(chunk)
        chunk == 'ならば'
      end

      def process_comp_3(chunk, options = { reverse?: false })
        case @last_token_type
        when Token::QUESTION
          @stack.pop # drop question
          comparison_tokens = [Token.new(Token::COMP_EQ)]
          comparison_tokens << Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE) if stack_is_truthy_check?
        when Token::COMP_2_LTEQ
          comparison_tokens = [Token.new(Token::COMP_LTEQ)]
        when Token::COMP_2_GTEQ
          comparison_tokens = [Token.new(Token::COMP_GTEQ)]
        else
          raise Errors::UnexpectedInput, chunk
        end

        flip_comparison comparison_tokens if options[:reverse?]
        close_if_statement comparison_tokens
      end
    end
  end
end
