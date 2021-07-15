require_relative 'util/i18n'

module Errors
  class BaseError < StandardError
    attr_writer :line_num

    def initialize(error_message = '')
      super error_message
    end
  end


  # Dynamically define custom error classes (using anonymous class objects).
  # send is used to bypass visibility on define_method, and definition with proc
  # is used to keep a reference to message (as opposed to a block passed to the
  # class initialisation which loses context).
  # See: config/i18n/en/tokenizer_errors.yaml
  # See: config/i18n/en/interpreter_errors.yaml
  def self.register_custom_errors(owner)
    file = owner.name.downcase.sub '::', '_'

    Util::I18n.messages(file).each do |error, message|
      owner.const_set error, Class.new(owner::BaseError)
      owner.const_get(error).send :define_method, :initialize, (proc { |*args| super format(message, *args) })
    end
  end
end
