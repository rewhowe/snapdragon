module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_be?(chunk)
        chunk == 'あれば'
      end

      ##
      # Despite the generic naming, this token presently only follows COMP_1_IN.
      def tokenize_comp_2_be(_chunk)
        close_if_statement [Token.new(Token::COMP_IN)]
      end
    end
  end
end
