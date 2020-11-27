module Tokenizer
  class Lexer
    module TokenLexers
      def comp_3?(chunk)
        chunk =~ /^ならば?$/
      end

      def tokenize_comp_3(chunk, options = { reverse?: false })
        comparison_tokens = {
          Token::QUESTION    => [Token.new(Token::COMP_EQ)],
          Token::COMP_2      => [Token.new(Token::COMP_EQ)],
          Token::COMP_2_LTEQ => [Token.new(Token::COMP_LTEQ)],
          Token::COMP_2_GTEQ => [Token.new(Token::COMP_GTEQ)],
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
