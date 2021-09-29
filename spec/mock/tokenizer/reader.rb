require './src/tokenizer/base_reader'

module Mock
  module Tokenizer
    # Mocking class which can use mocked input data instead of a file.
    class Reader < ::Tokenizer::BaseReader
      def initialize(mock_data)
        super()
        @mock_data = mock_data.chars
      end

      def read_char
        @mock_data.shift
      end

      def unread_char(char)
        @mock_data.unshift char
      end
    end
  end
end
