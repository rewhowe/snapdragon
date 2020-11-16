module Tokenizer
  class Lexer
    module TokenLexers
      def comp_3_neq?(chunk)
        chunk =~ /^(等|ひと)しくなければ$/
      end

      def tokenize_comp_3_neq(_chunk)
        close_if_statement [Token.new(Token::COMP_NEQ)]
      end
    end
  end
end
