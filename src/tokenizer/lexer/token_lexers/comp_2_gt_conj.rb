module Tokenizer
  class Lexer
    module TokenLexers
      # rubocop:disable Layout/MultilineOperationIndentation
      def comp_2_gt_conj?(chunk)
        chunk =~ /\A(大|おお)きく\z/ ||
        chunk =~ /\A(長|なが)く\z/   ||
        chunk =~ /\A(高|たか)く\z/   ||
        chunk =~ /\A(多|おお)く\z/   ||
        false
      end
      # rubocop:enable Layout/MultilineOperationIndentation

      def tokenize_comp_2_gt_conj(_chunk)
        @stack.insert last_condition_index_from_stack, Token.new(Token::COMP_GT)
        Token.new Token::COMP_2 # for flavour
      end
    end
  end
end
