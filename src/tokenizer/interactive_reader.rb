require_relative 'base_reader'
require_relative 'errors'

module Tokenizer
  class InteractiveReader < BaseReader
    MODE_SINGLE_LINE = 1
    MODE_MULTI_LINE  = 2

    def initialize()
      super()
      @input_buffer = []
    end

    def reopen
      @is_input_closed = false
    end

    private

    def read_char
      get_input if @input_buffer.empty?

      char = @input_buffer.shift

      if char == '\\'
        @input_buffer.clear
        char = "\n"
        @mode = MODE_MULTI_LINE
      end

      char
    end

    def unread_char(char)
      @input_buffer.unshift char
    end

    private

    def get_input
      print '> '
      input = gets
      if input == "\n"
        input = "・・・\n"
        @mode = MODE_SINGLE_LINE
      elsif input.nil?
        raise Interrupt
      end
      @input_buffer = input.chars
      @input_buffer += [nil] if @mode == MODE_SINGLE_LINE
    rescue SystemExit, Interrupt
      puts "\n"
      exit
    end
  end
end
