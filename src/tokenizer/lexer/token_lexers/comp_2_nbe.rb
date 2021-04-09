module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_nbe?(chunk)
        chunk == 'なければ'
      end

      ##
      # Despite the generic naming, this token presently only follows COMP_1_IN.
      def tokenize_comp_2_nbe(_chunk)
        close_if_statement [Token.new(Token::COMP_NIN)]
      end
    end
  end
end
