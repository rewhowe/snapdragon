module Tokenizer
  class Lexer
    module TokenLexers
      def comma?(chunk)
        chunk =~ /^[#{COMMA}]$/
      end

      def process_comma(_chunk)
        raise Errors::UnexpectedComma unless @context.inside_assignment?

        unless @context.inside_array?
          @stack.insert @stack.index { |t| t.type == Token::ASSIGNMENT } + 1, Token.new(Token::ARRAY_BEGIN)
          @context.inside_array = true
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
