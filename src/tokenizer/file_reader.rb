require_relative 'base_reader'

module Tokenizer
  class FileReader < BaseReader
    # Params:
    # +options+:: available options:
    #             * filename - input file to read from
    def initialize(options = {})
      super()

      @file = File.open options[:filename], 'r'
      ObjectSpace.define_finalizer(self, proc { @file.close unless @is_input_closed })
    end

    private

    def close_input
      @file.close
      @is_input_closed = true
    end

    def read_char
      @file.getc
    end

    def unread_char(char)
      @file.ungetc char
    end
  end
end
