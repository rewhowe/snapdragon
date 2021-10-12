require_relative '../interpreter/return_value'
require_relative '../string'
require_relative '../errors'

module Util
  class Repl
    private_class_method :new

    class << self
      def run(reader, processor)
        loop do
          begin
            reader.reopen
            result = processor.execute
            exit result.result_code if result.is_a? Interpreter::ReturnValue
          rescue Errors::BaseError => e
            puts e.message.red
            processor.reset
          end
        end
      end
    end
  end
end
