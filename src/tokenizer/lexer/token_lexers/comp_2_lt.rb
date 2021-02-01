module Tokenizer
  class Lexer
    module TokenLexers
      # rubocop:disable Layout/MultilineOperationIndentation
      # rubocop:disable Layout/SpaceAroundOperators
      def comp_2_lt?(chunk)
        chunk =~ /\A(小|ちい)さければ\z/ ||
        chunk =~ /\A(短|みじか)ければ\z/ ||
        chunk =~ /\A(低|ひく)ければ\z/   ||
        chunk =~ /\A(少|すく)なければ\z/ ||
        false
      end
      # rubocop:enable Layout/MultilineOperationIndentation
      # rubocop:enable Layout/SpaceAroundOperators

      def tokenize_comp_2_lt(_chunk)
        close_if_statement [Token.new(Token::COMP_LT)]
      end
    end
  end
end
