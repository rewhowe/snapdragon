module Interpreter
  class Formatter
    private_class_method :new

    class << self
      def output(value)
        case value
        when NilClass then 'null'
        when String   then "\"#{value}\""
        when Numeric  then format_numeric value
        when SdArray  then format_sd_array value
        else value.to_s
        end
      end

      def interpolated(value)
        case value
        when TrueClass  then 'はい'
        when FalseClass then 'いいえ'
        when Numeric    then format_numeric value
        when SdArray    then format_sd_array value
        else value.to_s
        end
      end

      private

      def format_numeric(value)
        value.to_i == value ? value.to_i.to_s : value.to_s
      end

      def format_sd_array(value)
        "{#{value.map { |k, v| "#{output k.numeric? ? k.to_f : k}: #{output v}" } .join ', '}}"
      end
    end
  end
end
