require_relative '../string'
require_relative '../errors'

module Tokenizer
  module Errors
    # Relative to project root
    CUSTOM_ERROR_PATH = "#{__dir__}/../../config/tokenizer_errors.yaml".freeze

    class BaseError < ::Errors::BaseError
      def message
        line_message = @line_num ? "\nAn error occurred while tokenizing on line #{@line_num}\n" : ''
        "#{line_message}#{super}"
      end
    end

    ::Errors.register_custom_errors Tokenizer::Errors, CUSTOM_ERROR_PATH

    class SequenceUnmatched < StandardError
      def initialize(sequence = nil)
        return unless sequence
        super sequence[:token] || begin
          terms = (sequence[:sub_sequence] || sequence[:branch_sequence]).map { |s| s[:token] || '[...]' }
          terms.join sequence[:sub_sequence] ? ' > ' : ' | '
        end .to_s
      end
    end
  end
end
