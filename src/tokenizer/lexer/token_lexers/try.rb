module Tokenizer
  class Lexer
    module TokenLexers
      def try?(chunk)
        chunk =~ /\A(試|ため)す\z/
      end

      def tokenize_try(_chunk)
        token = Token.new Token::TRY
        @stack << token
        begin_scope Scope::TYPE_TRY
        token
      end
    end
  end
end
