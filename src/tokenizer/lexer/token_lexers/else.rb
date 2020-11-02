module Tokenizer
  class Lexer
    module TokenLexers
      def else?(chunk)
        chunk =~ /^(それ以外|(違|ちが)えば)$/
      end

      def process_else(_chunk)
        raise Errors::UnexpectedElse unless @context.inside_if_block?
        token = Token.new Token::ELSE
        @stack << token
        close_if_statement
        token
      end
    end
  end
end
