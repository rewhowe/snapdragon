module Interpreter
  class Processor
    module TokenProcessors
      def process_return(_token)
        ReturnValue.new resolve_variable! @stack
      end
    end
  end
end
