module Tokenizer
  class Lexer
    module TokenLexers
      # rubocop:disable Layout/ExtraSpacing
      # rubocop:disable Layout/MultilineOperationIndentation
      # rubocop:disable Layout/SpaceAroundOperators
      def else?(chunk)
        chunk =~ /^それ以外(ならば?|は|だと)$/ ||
        chunk =~ /^(違|ちが)(うならば?|えば)$/ ||
        chunk =~ /^(じゃ|で)なければ/          ||
        false
      end
      # rubocop:enable Layout/ExtraSpacing
      # rubocop:enable Layout/MultilineOperationIndentation
      # rubocop:enable Layout/SpaceAroundOperators

      def tokenize_else(_chunk)
        raise Errors::UnexpectedElse unless @context.inside_if_block?
        token = Token.new Token::ELSE
        @stack << token
        close_if_statement
        token
      end
    end
  end
end
