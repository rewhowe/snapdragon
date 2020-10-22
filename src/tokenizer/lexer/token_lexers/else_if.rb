module Tokenizer
  class Lexer
    module TokenLexers
      def else_if?(chunk)
        chunk =~ /^(もしくは|または)$/
      end

      def process_else_if(_chunk)
        raise Errors::UnexpectedElseIf unless @context.inside_if_block?
        @context.inside_if_condition = true
        (@tokens << Token.new(Token::ELSE_IF)).last
      end
    end
  end
end