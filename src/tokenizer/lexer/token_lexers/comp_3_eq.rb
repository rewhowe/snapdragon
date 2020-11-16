module Tokenizer
  class Lexer
    module TokenLexers
      def comp_3_eq?(chunk)
        chunk =~ /^(等|ひと)しければ$/
      end

      def tokenize_comp_3_eq(_chunk)
        close_if_statement [Token.new(Token::COMP_EQ)]
      end
    end
  end
end
