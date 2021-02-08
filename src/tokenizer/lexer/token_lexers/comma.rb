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

        if eol? @reader.peek_next_chunk
          # eat until peeked EOL token, then discard it
          loop while whitespace? @reader.next_chunk
        end
        raise Errors::UnexpectedEof if @reader.peek_next_chunk.empty?

        (@stack << Token.new(Token::COMMA)).last
      end
    end
  end
end
