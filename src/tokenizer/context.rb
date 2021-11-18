require_relative '../token'

module Tokenizer
  # This class keeps track of the current context while lexing.
  # Certain tokens are only valid within certain contexts, even if they are
  # valid according to the token sequence.
  # Ex. ELSE_IF is a valid token following EOL, but only within the context
  # of an if block.
  class Context
    attr_accessor :last_token_type
    attr_accessor :current_function_def

    def initialize
      # The last token parsed in the sequence. It may not be present in the @stack or @output_buffer, but is guaranteed
      # to represent the last token parsed. Some tokens may be generalised, such as COMP_1 or COMP_2.
      @last_token_type = Token::EOL

      # The current top-level function def. Required for aborting function definition in interactive mode.
      @current_function_def = nil
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
