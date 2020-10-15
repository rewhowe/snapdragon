module Tokenizer
  module Errors

    # Relative to project root
    CUSTOM_ERROR_PATH = './config/tokenizer_errors.yaml'.freeze

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

    CUSTOM_ERRORS = YAML.load_file CUSTOM_ERROR_PATH

    CUSTOM_ERRORS.each do |error, message|
      const_set error, Class.new(LexerError) do
        define_method 'initialize' do |args|
          super printf(message, *args)
        end
      end
    end
  end
end
