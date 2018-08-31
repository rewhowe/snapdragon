module Tokenizer
  module Errors
    class LexerError < StandardError
      attr_writer :line_num

      def initialize(message = '')
        super message
      end

      def message
        line_message = @line_num ? "\nAn error occurred while tokenizing on line #{@line_num}" : ''
        puts "#{line_message}\n#{super}".red
      end
    end

    # custom errors

    class UnexpectedIndent < LexerError
      def initialize
        super 'Unexpected indent'
      end
    end
  end
end
