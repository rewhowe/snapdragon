require 'YAML'

require_relative '../colour_string.rb'

module Tokenizer
  module Errors
    # Relative to project root
    CUSTOM_ERROR_PATH = './config/tokenizer_errors.yaml'.freeze

    class BaseError < StandardError
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

    # Dynamically define custom error classes (using anonymous class objects).
    # send is used to bypass visibility on define_method, and definition with
    # proc is used to keep a reference to message (as opposed to a block passed
    # to the class initialisation which loses context).
    CUSTOM_ERRORS.each do |error, message|
      const_set error, Class.new(BaseError)
      const_get(error).send 'define_method', 'initialize', (proc { |*args| super format(message, *args) })
    end
  end
end
