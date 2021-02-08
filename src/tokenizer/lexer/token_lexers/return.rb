module Tokenizer
  class Lexer
    module TokenLexers
      def return?(chunk)
        chunk =~ /\A((返|かえ)(す|る)|(戻|もど)る|なる)\z/
      end

      # Adds implicit それ for 返す and 無 for 返る/戻る.
      def tokenize_return(chunk)
        parameter_token = @stack.pop

        if parameter_token.nil?
          parameter_token = begin
            case chunk
            when /\A(返|かえ)す\z/
              Token.new Token::PARAMETER, 'それ', particle: 'を', sub_type: Token::VAR_SORE
            when /\A(返|かえ|戻|もど)る\z/
              Token.new Token::PARAMETER, '無', particle: 'を', sub_type: Token::VAL_NULL
            end
          end
        end

        property_owner_token = @stack.pop
        validate_return_parameter chunk, parameter_token, property_owner_token

        @stack += [property_owner_token, parameter_token].compact
        (@stack << Token.new(Token::RETURN)).last
      end
    end
  end
end
