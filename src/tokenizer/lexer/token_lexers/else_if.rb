module Tokenizer
  class Lexer
    module TokenLexers
      def else_if?(chunk)
        %w[もしくは または].include? chunk
      end

      def process_else_if(_chunk)
        raise Errors::UnexpectedElseIf unless @context.inside_if_block?
        (@stack << Token.new(Token::ELSE_IF)).last
      end
    end
  end
end
