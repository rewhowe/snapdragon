module Tokenizer
  class Lexer
    module TokenLexers
      def comma?(chunk)
        chunk =~ /\A[#{COMMA}]\z/
      end

      def tokenize_comma(_chunk)
        if Context.inside_assignment?(@stack) && !Context.inside_array?(@stack)
          @stack.insert @stack.index { |t| t.type == Token::ASSIGNMENT } + 1, Token.new(Token::ARRAY_BEGIN)
        end

        if eol? peek_next_chunk_in_seq
          # eat until peeked EOL token, then discard it
          loop while whitespace? discard_next_chunk_in_seq!
        end
        raise Errors::UnexpectedEof if peek_next_chunk_in_seq.empty?

        (@stack << Token.new(Token::COMMA)).last
      end
    end
  end
end
