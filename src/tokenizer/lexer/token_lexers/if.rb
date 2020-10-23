module Tokenizer
  class Lexer
    module TokenLexers
      def if?(chunk)
        chunk == 'もし'
      end

      def process_if(_chunk)
        @context.inside_if_condition = true
        (@tokens << Token.new(Token::IF)).last
      end
    end
  end
end
