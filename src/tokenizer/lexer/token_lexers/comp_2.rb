module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2?(chunk)
        chunk =~ /\Aならば?\z/
      end

      def tokenize_comp_2(chunk, options = { reverse?: false })
        comparison_tokens = {
          Token::QUESTION    => [Token.new(Token::COMP_EQ)],
          Token::COMP_1      => [Token.new(Token::COMP_EQ)],
          Token::COMP_1_LTEQ => [Token.new(Token::COMP_LTEQ)],
          Token::COMP_1_GTEQ => [Token.new(Token::COMP_GTEQ)],
          Token::COMP_1_EMP  => [Token.new(Token::COMP_EMP)],
        }[@context.last_token_type]

        raise Errors::UnexpectedInput, chunk if comparison_tokens.nil?

        if @context.last_token_type == Token::QUESTION
          if stack_is_truthy_check?
            comparison_tokens << Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE)
          else # function call
            @stack.pop # drop question
          end
        end

        flip_comparison comparison_tokens if options[:reverse?]
        close_if_statement comparison_tokens
      end
    end
  end
end
