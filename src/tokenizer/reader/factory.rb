require_relative '../../util/options'
require_relative 'file_reader'
require_relative 'interactive_reader'

module Tokenizer
  module Reader
    class Factory
      private_class_method :new

      class << self
        def make(options = {})
          case options[:input]
          when Util::Options::INPUT_INTERACTIVE then InteractiveReader.new
          # Util::Options::INPUT_FILE
          else FileReader.new options
          end
        end
      end
    end
  end
end
