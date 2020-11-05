module Interpreter
  class ReturnValue
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def result_code
      return @value.to_i   if @value.is_a? Numeric
      return @value.length if @value.is_a?(String) || @value.is_a?(Array)
      @value ? 0 : 1
    end
  end
end
