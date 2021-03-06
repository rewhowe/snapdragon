require_relative '../token'

module Tokenizer
  # This class keeps track of the current context while lexing.
  # Certain tokens are only valid within certain contexts, even if they are
  # valid according to the token sequence.
  # Ex. ELSE_IF is a valid token following EOL, but only within the context
  # of an if block.
  class Context
    INSIDE_IF_BLOCK = 0b1

    attr_accessor :last_token_type

    def initialize
      # The current status of the lexer represented by a series of bit flags.
      @status = 0b0

      # The last token parsed in the sequence. It may not be present in the @stack or @output_buffer, but is guaranteed
      # to represent the last token parsed. Some tokens may be generalised, such as COMP_1 or COMP_2.
      @last_token_type = Token::EOL
    end

    # Using bit flags is (almost) completely unnecessary, but it allows me to
    # add additional status flags without writing any additional code.
    # Of course the code below is a lot less readable than it should be, but
    # Rule of Cool™.
    constants.each do |status|
      flag_value = Context.const_get(status)

      # If b is true: OR the status with the flag value (set the flag)
      # Otherwise: AND the status with the NOT'd flag value (unset the flag)
      define_method "#{status.downcase}=" do |b|
        @status = @status.send(*(b ? [:|, flag_value] : [:&, ~flag_value]))
      end

      define_method "#{status.downcase}?" do
        (@status & Context.const_get(status)).nonzero?
      end
    end

    class << self
      def inside_assignment?(stack)
        !stack.find { |t| t.type == Token::ASSIGNMENT } .nil?
      end

      def inside_array?(stack)
        !stack.find { |t| t.type == Token::ARRAY_BEGIN } .nil?
      end
    end
  end
end
