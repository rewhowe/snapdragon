module Tokenizer
  class Lexer
    module TokenLexers
      # rubocop:disable Layout/MultilineOperationIndentation
      def comp_3_gt?(chunk)
        chunk =~ /^(大|おお)きければ$/ ||
        chunk =~ /^(長|なが)ければ$/   ||
        chunk =~ /^(高|たか)ければ$/   ||
        chunk =~ /^(多|おお)ければ$/   ||
        false
      end
      # rubocop:enable all

      def process_comp_3_gt(_chunk)
        close_if_statement [Token.new(Token::COMP_GT)]
      end
    end
  end
end
