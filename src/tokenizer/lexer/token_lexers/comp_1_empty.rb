module Tokenizer
  class Lexer
    module TokenLexers
      def comp_1_empty?(chunk)
        chunk == '空' || chunk == 'から'
      end

      def tokenize_comp_1_empty(_chunk)
        # TODO: add nothign?
        Token.new Token::COMP_1_EMPTY
      end
    end
  end
end
