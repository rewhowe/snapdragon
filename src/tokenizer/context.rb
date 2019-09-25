module Tokenizer
  # This class keeps track of the current context while lexing.
  # Certain tokens are only valid within certain contexts, even if they are
  # valid according to the token sequence.
  # Ex. ELSE_IF is a valid token following EOL, but only within the context
  # of an if block.
  class Context
    INSIDE_ARRAY        = 0b1
    INSIDE_IF_CONDITION = 0b10
    INSIDE_IF_BLOCK     = 0b100

    def initialize
      @status = 0b0
    end

    # Using bit flags is (almost) completely unnecessary, but it allows me to
    # add additional status flags without writing any additional code.
    # Of course the code below is a lot less readable than it should be,
    # but Rule of Cool™.
    # This block demonstrates:
    # * Dynamic method definitions (constants.each define_method)
    # * Dynamic method calls (send)
    # * Splat usage (*)
    # * Bitwise operations as method names (:|, :&)
    self.constants.each do |status|
      flag_value = Context.const_get(status)

      # If b is true, OR the status with the flag value (set the flag)
      # Otherwise, AND the status with the NOT'd flag value (unset the flag)
      define_method "#{status.downcase}=" do |b|
        @status = @status.send(*(b ? [:|, flag_value] : [:&, ~flag_value]))
      end

      define_method "#{status.downcase}?" do
        (@status & Context.const_get(status)).nonzero?
      end
    end
  end
end
