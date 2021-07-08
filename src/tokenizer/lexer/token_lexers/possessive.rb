module Tokenizer
  class Lexer
    module TokenLexers
      # Intentionally use a strict, non-erroring, validating match to avoid
      # false positives. The bulk of the real validation is performed with the
      # property, so the grammar can differentiate between POSSESSIVE and RVALUE
      # before then.
      def possessive?(chunk)
        return false unless chunk =~ /\A.+の\z/

        variable = chunk.chomp 'の'
        sub_type = variable_type variable, validate?: false
        Oracles::Property.valid_property_owner?(sub_type) && (sub_type != Token::VARIABLE || variable?(variable))
      end

      def tokenize_possessive(chunk)
        chunk = chunk.chomp 'の'
        sub_type = variable_type chunk
        (@stack << Token.new(Token::POSSESSIVE, chunk, sub_type: sub_type)).last
      end
    end
  end
end
