require_relative '../errors'
require_relative '../util/i18n'

module Tokenizer
  module Errors
    class BaseError < ::Errors::BaseError
      def message
        line_message = @line_num ? Util::I18n.t('tokenizer.base_error', @line_num) + "\n" : ''
        "#{line_message}#{super}"
      end
    end

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
