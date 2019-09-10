module Util
  class Logger
    private_class_method :new

    @options = {}

    class << self
      def setup(options)
        @options = options

        debug @options
      end

      # TODO: in the future, maybe allow logging to file
      def debug(message)
        puts message if @options[:debug]
      end
    end
  end
end
