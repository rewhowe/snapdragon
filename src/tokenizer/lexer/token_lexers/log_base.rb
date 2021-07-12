module Tokenizer
  class Lexer
    module TokenLexers
      def log_base?(chunk)
        chunk =~ /\A(底|てい)と\z/
      end

      def tokenize_log_base(_chunk)
        Token.new Token::LOG_BASE # for flavour
      end
    end
  end
end
