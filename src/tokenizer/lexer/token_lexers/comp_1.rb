module Tokenizer
  class Lexer
    module TokenLexers
      # TODO: (v1.1.0) Remove inside_if_condition? check.
      def comp_1?(chunk)
        chunk =~ /.+が$/ && @context.inside_if_condition? && begin
          next_chunk = @reader.peek_next_chunk
          # TODO: change punctuation? to question?
          !eol?(next_chunk) && !punctuation?(next_chunk)
        end
      end

      def process_comp_1(chunk)
        @stack << comp_token(chunk.chomp('が'))
        Token.new Token::COMP_1
      end
    end
  end
end
