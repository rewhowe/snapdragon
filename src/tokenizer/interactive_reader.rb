require_relative 'base_reader'
require_relative 'errors'

module Tokenizer
  class InteractiveReader < BaseReader
    def initialize()
      super()
      @input_buffer = []
    end

    def reopen
      @is_input_closed = false
    end

    private

    def read_char
      if @input_buffer.empty?
        print '> '
        input = gets
        input = "・・・\n" if input == "\n"
        @input_buffer = input.chars + [nil]
      end
      @input_buffer.shift
    end

    def unread_char(char)
      @input_buffer.unshift char
    end
  end
end
