module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_eq?(chunk)
        chunk =~ /\A(等|ひと)しければ\z/
      end

      def tokenize_comp_2_eq(_chunk)
        close_if_statement [Token.new(Token::COMP_EQ)]
      end
    end
  end
end
