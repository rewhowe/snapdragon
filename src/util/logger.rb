require_relative 'options'

module Util
  class Logger
    private_class_method :new

    @options = {}

    class << self
      def setup(options)
        @options = options

        debug Options::DEBUG_3, @options
      end

      def debug(level, message)
        puts message if level >= @options[:debug]
      end
    end
  end
end
