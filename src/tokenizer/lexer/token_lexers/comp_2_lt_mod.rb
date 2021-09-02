module Tokenizer
  class Lexer
    module TokenLexers
      # rubocop:disable Layout/MultilineOperationIndentation
      # rubocop:disable Layout/SpaceAroundOperators
      def comp_2_lt_mod?(chunk)
        chunk =~ /\A(小|ちい)さい\z/ ||
        chunk =~ /\A(短|みじか)い\z/ ||
        chunk =~ /\A(低|ひく)い\z/   ||
        chunk =~ /\A(少|すく)ない\z/ ||
        false
      end
      # rubocop:enable Layout/MultilineOperationIndentation
      # rubocop:enable Layout/SpaceAroundOperators

      def tokenize_comp_2_lt_mod(_chunk)
        @stack.insert last_condition_index_from_stack, Token.new(Token::COMP_LT)
        Token.new Token::COMP_2 # for flavour
      end
    end
  end
end
