module Tokenizer
  class Lexer
    module TokenLexers
      def subject?(chunk)
        chunk =~ /.+が$/
      end

      # Presently only used in conditional expressions.
      def tokenize_subject(chunk)
        @stack << comp_token(chunk.chomp('が'))
        Token.new Token::SUBJECT
      end
    end
  end
end
