module Tokenizer
  class Lexer
    module TokenLexers
      # An rvalue is either a primitive, special identifier, or scoped variable.
      def rvalue?(chunk)
        Oracles::Value.value?(chunk) || @current_scope.variable?(chunk)
      end

      # TODO: (v1.1.0) Cannot assign keys / indices to themselves. (Fix at same time as tokenize_attribute)
      # No need to validate variable_type because the matcher checks either
      # primitive or existing variable.
      def tokenize_rvalue(chunk)
        chunk = Oracles::Value.sanitize chunk
        (@stack << Token.new(Token::RVALUE, chunk, sub_type: variable_type(chunk))).last
      end
    end
  end
end
