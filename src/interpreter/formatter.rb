module Interpreter
  class Formatter
    private_class_method :new

    class << self
      # rubocop:disable Metrics/CyclomaticComplexity
      def output(value)
        case value
        when NilClass then 'null'
        when String   then "\"#{value}\""
        when Float    then format_float value
        when Array    then "[#{value.map { |v| output v } .join ', '}]"
        when Hash     then "{#{value.map { |k, v| "#{k} => #{output v}" } .join ', '}}"
        else value.to_s
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def interpolated(value)
        case value
        when TrueClass  then 'はい'
        when FalseClass then 'いいえ'
        when Float      then format_float value
        when Array      then output value
        when Hash       then output value
        else value.to_s
        end
      end

      private

      def format_float(value)
        value.to_i == value ? value.to_i.to_s : value.to_s
      end
    end
  end
end
