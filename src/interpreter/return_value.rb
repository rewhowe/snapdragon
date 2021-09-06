require_relative 'sd_array'

module Interpreter
  class ReturnValue
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def result_code
      case @value
      when Numeric         then @value.to_i
      when String, SdArray then @value.length
      else                      @value ? 0 : 1
      end
    end
  end
end
