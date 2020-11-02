module Tokenizer
  class Lexer
    module TokenLexers
      # An rvalue is either a primitive, special identifier, or scoped variable.
      def rvalue?(chunk)
        Oracles::Value.value?(chunk) || @current_scope.variable?(chunk)
      end

      # TODO: (v1.1.0) Cannot assign keys / indices to themselves. (Fix at same time as process_attribute)
      # No need to validate variable_type because the matcher checks either
      # primitive or existing variable.
      def process_rvalue(chunk)
        chunk = sanitize_variable chunk
        (@stack << Token.new(Token::RVALUE, chunk, sub_type: variable_type(chunk))).last
      end
    end
  end
end
