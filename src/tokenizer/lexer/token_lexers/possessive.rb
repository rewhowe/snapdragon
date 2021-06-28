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
        raise Errors::InvalidPropertyOwner, chunk unless Oracles::Property.valid_property_owners.include? sub_type
        (@stack << Token.new(Token::POSSESSIVE, chunk, sub_type: sub_type)).last
      end
    end
  end
end
