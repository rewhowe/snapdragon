module Tokenizer
  class Lexer
    module TokenLexers
      def return?(chunk)
        chunk =~ /^((返|かえ)(す|る)|(戻|もど)る|なる)$/
      end

      # Adds implicit それ for 返す and 無 for 返る/戻る.
      def process_return(chunk)
        raise Errors::UnexpectedReturn, chunk if @context.inside_if_condition?

        parameter_token = @stack.pop

        if parameter_token.nil?
          parameter_token = begin
            case chunk
            when /^(返|かえ)す$/
              Token.new Token::PARAMETER, 'それ', particle: 'を', sub_type: Token::VAR_SORE
            when /^(返|かえ|戻|もど)る$/
              Token.new Token::PARAMETER, '無', particle: 'を', sub_type: Token::VAL_NULL
            end
          end
        end

        property_token = @stack.pop
        validate_return_parameter chunk, parameter_token, property_token

        # Something else was in the stack
        raise Errors::UnexpectedReturn, chunk unless @stack.empty?

        @tokens += [property_token, parameter_token].compact
        (@tokens << Token.new(Token::RETURN)).last
      end
    end
  end
end
