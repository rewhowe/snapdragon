module Tokenizer
  class Lexer
    module TokenLexers
      # rubocop:disable Layout/MultilineOperationIndentation
      # rubocop:disable Layout/SpaceAroundOperators
      def comp_2_lt_conj?(chunk)
        chunk =~ /\A(小|ちい)さく\z/ ||
        chunk =~ /\A(短|みじか)く\z/ ||
        chunk =~ /\A(低|ひく)く\z/   ||
        chunk =~ /\A(少|すく)なく\z/ ||
        false
      end
      # rubocop:enable Layout/MultilineOperationIndentation
      # rubocop:enable Layout/SpaceAroundOperators

      def tokenize_comp_2_lt_conj(_chunk)
        @stack.insert last_condition_index_from_stack, Token.new(Token::COMP_LT)
        Token.new Token::COMP_2 # for flavour
      end
    end
  end
end
