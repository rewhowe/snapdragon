module Tokenizer
  class Lexer
    module TokenLexers
      def else_if?(chunk)
        %w[もしくは または].include? chunk
      end

      def tokenize_else_if(_chunk)
        raise Errors::UnexpectedElseIf unless @current_scope.inside_if_block?
        (@stack << Token.new(Token::ELSE_IF)).last
      end
    end
  end
end
