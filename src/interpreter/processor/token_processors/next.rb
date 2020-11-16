module Interpreter
  class Processor
    module TokenProcessors
      def process_next(_token)
        ReturnValue.new Token::NEXT
      end
    end
  end
end
