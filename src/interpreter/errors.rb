require 'yaml'

require_relative '../colour_string'
require_relative '../errors'

module Interpreter
  module Errors
    # Relative to project root
    CUSTOM_ERROR_PATH = './config/interpreter_errors.yaml'.freeze

    class BaseError < ::Errors::BaseError
      def message
        line_message = @line_num ? "\nAn error occurred during execution on line #{@line_num}" : ''
        puts "#{line_message}\n#{super}".red
      end
    end

    ::Errors.register_custom_errors Interpreter::Errors, CUSTOM_ERROR_PATH
  end
end
