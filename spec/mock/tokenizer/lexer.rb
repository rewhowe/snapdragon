module Mock
  module Tokenizer
    class Lexer
      def initialize(mock_tokens)
        @tokens = mock_tokens
      end

      def next_token
        @tokens.shift
      end

      def line_num
        0
      end
    end
  end
end
