require './src/tokenizer/reader'

module Mock
  module Tokenizer
    # Mocking class which can used initalized data instead of a file.
    # NOTE: Actually this still relies a lot on the internal logic, so it's
    # not a completely pure mock.
    class Reader < ::Tokenizer::Reader
      def initialize(mock_data)
        @options = {}

        @chunk         = ''
        @line_num      = 1
        @output_buffer = []
        @is_finished   = false
        # mock @file.closed? for peek_next_chunk
        @file = Class.new {
          def closed?
            false
          end
        } .new

        @mock_data = mock_data.chars
      end

      def finish
        @is_finished = true
      end

      def finished?
        @is_finished && @output_buffer.empty?
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
