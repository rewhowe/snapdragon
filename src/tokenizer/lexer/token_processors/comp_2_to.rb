module Tokenizer
  class Lexer
    module TokenProcessors
      def comp_2_to?(chunk)
        chunk =~ /.+と$/ && begin
          next_chunk = @reader.peek_next_chunk
          comp_3_eq?(next_chunk) || comp_3_neq?(next_chunk)
        end
      end

      def process_comp_2_to(chunk)
        @stack << comp_token(chunk.chomp('と'))
        Token.new Token::COMP_2_TO
      end
    end
  end
end
