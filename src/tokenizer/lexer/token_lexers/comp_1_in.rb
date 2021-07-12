module Tokenizer
  class Lexer
    module TokenLexers
      def comp_1_in?(chunk)
        chunk =~ /\A(中|なか)に\z/
      end

      ##
      # Rip out previous POSSESSIVE token and convert to RVALUE.
      def tokenize_comp_1_in(_chunk)
        container_token = @stack.pop

        sub_type = container_token.sub_type
        valid_containers = [Token::VARIABLE, Token::VAR_SORE, Token::VAR_ARE, Token::VAL_STR]
        raise Errors::NotAValidContainer, container_token.content unless valid_containers.include? sub_type

        container_token.type = Token::RVALUE
        @stack << container_token

        Token.new Token::COMP_1_IN
      end
    end
  end
end
