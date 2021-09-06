module Tokenizer
  class Lexer
    module TokenLexers
      def comp_1_eq?(chunk)
        chunk =~ /\A(同|おな)じ\z/
      end

      def tokenize_comp_1_eq(_chunk)
        Token.new Token::COMP_1_EQ
      end
    end
  end
end
