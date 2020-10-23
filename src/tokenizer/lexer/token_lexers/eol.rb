module Tokenizer
  class Lexer
    module TokenLexers
      def eol?(chunk)
        chunk == "\n"
      end

      # On eol, check the indent for the next line.
      # Because whitespace is not tokenized, it is difficult to determine the
      # indent level when encountering a non-whitespace chunk. If we check on eol,
      # we can peek at the amount of whitespace present before it is stripped.
      def process_eol(_chunk)
        raise Errors::UnexpectedEol if @context.inside_if_condition?
        process_indent
        Token.new Token::EOL
      end
    end
  end
end
