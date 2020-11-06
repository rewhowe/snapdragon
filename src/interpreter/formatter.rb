module Interpreter
  class Formatter
    private_class_method :new

    class << self
      def format_output(value)
        return 'null' if value.nil?
        return "[#{value.map { |v| format_output v } .join ', '}]" if value.is_a? Array
        return "{#{value.map { |k, v| "#{k} => #{format_output v}" } .join ', ' }}" if value.is_a? Hash
        value.to_s
      end
    end
  end
end
