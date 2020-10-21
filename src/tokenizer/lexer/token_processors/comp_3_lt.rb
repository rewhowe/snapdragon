module Tokenizer
  class Lexer
    module TokenProcessors
      # rubocop:disable Layout/MultilineOperationIndentation
      # rubocop:disable Layout/SpaceAroundOperators
      def comp_3_lt?(chunk)
        chunk =~ /^(小|ちい)さければ$/ ||
        chunk =~ /^(短|みじか)ければ$/ ||
        chunk =~ /^(低|ひく)ければ$/   ||
        chunk =~ /^(少|すく)なければ$/ ||
        false
      end
      # rubocop:enable all

      def process_comp_3_lt(_chunk)
        close_if_statement [Token.new(Token::COMP_LT)]
      end
    end
  end
end
