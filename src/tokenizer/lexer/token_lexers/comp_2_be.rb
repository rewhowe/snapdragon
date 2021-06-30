module Tokenizer
  class Lexer
    module TokenLexers
      def comp_2_be?(chunk)
        chunk == 'あれば'
      end

      ##
      # Despite the generic naming, this token presently only follows COMP_1_IN.
      def tokenize_comp_2_be(_chunk, options = { reverse?: false })
        comparison_tokens = [Token.new(Token::COMP_IN)]
        flip_comparison comparison_tokens if options[:reverse?]
        close_if_statement comparison_tokens
      end
    end
  end
end
