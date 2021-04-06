module Tokenizer
  class Lexer
    module TokenLexers
      def comp_1_emp?(chunk)
        %w[空 から].include? chunk
      end

      def tokenize_comp_1_emp(_chunk)
        Token.new Token::COMP_1_EMP
      end
    end
  end
end
