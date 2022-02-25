module Util
  class Logger
    private_class_method :new

    @options = {}

    class << self
      def setup(options)
        @options = options
      end

      ##
      # Debug messages are passed via block. This is to avoid having message
      # formatting affect performance when debugging is disabled.
      def debug(level)
        puts yield if level >= @options[:debug]
      end
    end
  end
end
