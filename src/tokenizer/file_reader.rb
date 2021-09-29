require_relative 'base_reader'

module Tokenizer
  class FileReader < BaseReader
    # Params:
    # +options+:: available options:
    #             * filename - input file to read from
    def initialize(options = {})
      super options

      @file = File.open options[:filename], 'r'
      ObjectSpace.define_finalizer(self, proc { @file.close unless @is_finished })
    end

    private

    def finish
      @file.close
      @is_finished = true
    end

    def next_char
      char = @file.getc
      @line_num += 1 if char == "\n"
      char
    end

    def restore_char(char)
      @file.ungetc char
      @line_num -= 1 if char == "\n"
    end
  end
end
