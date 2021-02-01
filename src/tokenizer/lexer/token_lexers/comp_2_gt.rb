module Tokenizer
  class Lexer
    module TokenLexers
      # rubocop:disable Layout/MultilineOperationIndentation
      def comp_2_gt?(chunk)
        chunk =~ /\A(大|おお)きければ\z/ ||
        chunk =~ /\A(長|なが)ければ\z/   ||
        chunk =~ /\A(高|たか)ければ\z/   ||
        chunk =~ /\A(多|おお)ければ\z/   ||
        false
      end
      # rubocop:enable Layout/MultilineOperationIndentation

      def tokenize_comp_2_gt(_chunk)
        close_if_statement [Token.new(Token::COMP_GT)]
      end
    end
  end
end
