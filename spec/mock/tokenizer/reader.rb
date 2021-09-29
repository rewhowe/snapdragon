require './src/tokenizer/base_reader'

module Mock
  module Tokenizer
    # Mocking class which can use mocked input data instead of a file.
    class Reader < ::Tokenizer::BaseReader
      def initialize(mock_data)
        super {}
        @mock_data = mock_data.chars
      end

      def next_char
        char = @mock_data.shift
        @line_num += 1 if char == "\n"
        char
      end

      def restore_char(char)
        @mock_data.unshift char
        @line_num -= 1 if char == "\n"
      end
    end
  end
end
