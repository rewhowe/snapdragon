module Tokenizer
  class Lexer
    module TokenLexers
      # If followed by punctuation, this might be a variable name.
      def property?(chunk)
        chunk =~ /^.+の$/ && begin
          next_chunk = @reader.peek_next_chunk
          !eol?(next_chunk) && !punctuation?(next_chunk)
        end
      end

      def process_property(chunk)
        chunk.chomp! 'の'
        sub_type = variable_type chunk
        # TODO: (v1.1.0) Allow Token::VAL_NUM for Exp, Log, and Root.
        valid_property_owners = [Token::VARIABLE, Token::VAR_SORE, Token::VAR_ARE, Token::VAL_STR]
        raise Errors::InvalidPropertyOwner, chunk unless valid_property_owners.include? sub_type
        (@stack << Token.new(Token::PROPERTY, chunk, sub_type: sub_type)).last
      end
    end
  end
end
