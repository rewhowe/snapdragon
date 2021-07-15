require_relative '../errors'
require_relative '../util/i18n'

module Interpreter
  module Errors
    class BaseError < ::Errors::BaseError
      def message
        line_message = @line_num ? "\n" + Util::I18n.t('interpreter.base_error', @line_num) + "\n" : ''
        "#{line_message}#{super}"
      end
    end
  end
end
