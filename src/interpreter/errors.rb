module Interpreter
  module Errors
    class BaseError < ::Errors::BaseError
      def message
        line_message = @line_num ? "\nAn error occurred during execution on line #{@line_num}\n" : ''
        "#{line_message}#{super}"
      end
    end
  end
end
