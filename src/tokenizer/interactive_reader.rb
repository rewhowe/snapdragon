require 'readline'

require_relative 'base_reader'
require_relative 'errors'

module Tokenizer
  class InteractiveReader < BaseReader
    MODE_SINGLE_LINE = 1
    MODE_MULTI_LINE  = 2

    def initialize()
      super()
      @input_buffer = []
      @mode = MODE_SINGLE_LINE
    end

    def reopen
      @is_input_closed = false
    end

    private

    def read_char
      get_input if @input_buffer.empty?

      if start_multiline?
        @input_buffer.clear
        @mode = MODE_MULTI_LINE
        "\n"
      else
        @input_buffer.shift
      end
    end

    def unread_char(char)
      @input_buffer.unshift char
    end

    private

    def get_input
      loop do
        begin
          input = prompt

          raise SystemExit if input.nil?

          if input == "\n"
            input = "・・・\n"
            @mode = MODE_SINGLE_LINE
          end

          @input_buffer += input.chars

          if @mode == MODE_SINGLE_LINE
            @input_buffer += [nil]
            break
          end
        rescue SystemExit
          puts "\n"
          exit
        rescue Interrupt
          print "\n"
        end
      end
    end

    def prompt
      prompt_char = { MODE_SINGLE_LINE => '>', MODE_MULTI_LINE => '*' }[@mode]
      Readline.readline("金魚草:#{@line_num + 1} #{prompt_char} ", true) + "\n"
    end

    def start_multiline?
      ["\\\n", "￥\n"].include? @input_buffer.join
    end
  end
end
