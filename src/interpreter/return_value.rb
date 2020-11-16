module Interpreter
  class ReturnValue
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def result_code
      case @value.class
      when Numeric       then @value.to_i
      when String, Array then @value.length
      else                    @value ? 0 : 1
      end
    end
  end
end
