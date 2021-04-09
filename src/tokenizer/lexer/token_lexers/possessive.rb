module Tokenizer
  class Lexer
    module TokenLexers
      def possessive?(chunk)
        variable = chunk.chomp 'の'
        # TODO: (feature/additional-math) Allow Token::VAL_NUM for Exp, Log, and Root.
        chunk =~ /\A.+の\z/ && (Oracles::Value.string?(variable) || variable?(variable))
      end

      def tokenize_possessive(chunk)
        chunk = chunk.chomp 'の'
        sub_type = variable_type chunk
        # NOTE: Redundant check; untested
        valid_property_owners = [Token::VARIABLE, Token::VAR_SORE, Token::VAR_ARE, Token::VAL_STR]
        raise Errors::InvalidPropertyOwner, chunk unless valid_property_owners.include? sub_type
        (@stack << Token.new(Token::POSSESSIVE, chunk, sub_type: sub_type)).last
      end
    end
  end
end
