module Interpreter
  class Formatter
    private_class_method :new

    class << self
      # rubocop:disable Metrics/CyclomaticComplexity
      def output(value)
        case value
        when NilClass then 'null'
        when String   then "\"#{value}\""
        when Float    then value.to_i == value ? value.to_i.to_s : value.to_s
        when Array    then "[#{value.map { |v| output v } .join ', '}]"
        when Hash     then "{#{value.map { |k, v| "#{k} => #{output v}" } .join ', '}}"
        else value.to_s
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end
