module Interpreter
  class Processor
    module TokenProcessors
      def process_break(_token)
        ReturnValue.new Token::BREAK
      end
    end
  end
end
