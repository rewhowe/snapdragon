require './src/tokenizer/lexer'

module Mock
  module Tokenizer
    # Reuse the real tokenizer for runtime tokenizing for string interpolation.
    class Lexer < ::Tokenizer::Lexer
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
