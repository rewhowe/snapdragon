module Tokenizer
  class Lexer
    module TokenLexers
      # rubocop:disable Layout/ExtraSpacing
      # rubocop:disable Layout/MultilineOperationIndentation
      # rubocop:disable Layout/SpaceAroundOperators
      def else?(chunk)
        chunk =~ /\Aそれ以外(ならば?|は|だと)\z/ ||
        chunk =~ /\A(違|ちが)(うならば?|えば)\z/ ||
        chunk =~ /\A(じゃ|で)なければ\z/         ||
        false
      end
      # rubocop:enable Layout/ExtraSpacing
      # rubocop:enable Layout/MultilineOperationIndentation
      # rubocop:enable Layout/SpaceAroundOperators

      def tokenize_else(_chunk)
        raise Errors::UnexpectedElse unless @current_scope.inside_if_block?
        token = Token.new Token::ELSE
        @stack << token
        close_if_statement
        token
      end
    end
  end
end
