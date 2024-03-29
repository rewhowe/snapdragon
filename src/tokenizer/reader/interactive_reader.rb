require 'readline'

require_relative '../../colour_string'
require_relative 'base_reader'

module Tokenizer
  module Reader
    class InteractiveReader < BaseReader
      MODE_SINGLE_LINE = 1
      MODE_MULTI_LINE  = 2

      def initialize
        super()
        @input_buffer = []
        @mode = MODE_SINGLE_LINE

        # line_num holds the number of the line currently being interpreted,
        # whereas prompt_line_num is holds the number to display on the prompt.
        @prompt_line_num = 1
      end

      def reopen
        @is_input_closed = false
      end

      def reset
        @input_buffer.clear
        @output_buffer.clear
        @chunk = ''
        @mode = MODE_SINGLE_LINE
        close_input
      end

      private

      def read_char
        read_input if @input_buffer.empty?

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

      def read_input
        loop do
          begin
            input = prompt

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
        input = Readline.readline(
          '金魚草'.blue + ':' + @prompt_line_num.to_s.lpink + " #{prompt_char} ",
          true
        )
        raise SystemExit if input.nil?
        @prompt_line_num += 1
        input + "\n"
      end

      def start_multiline?
        ["\\\n", "￥\n"].include? @input_buffer.join
      end
    end
  end
end
