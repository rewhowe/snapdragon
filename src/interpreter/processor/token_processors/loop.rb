module Interpreter
  class Processor
    module TokenProcessors
      def process_loop(_token)
        loop_range = loop_range_from_stack!

        body_tokens = next_tokens_from_scope_body

        current_scope = @current_scope                                           # save current scope
        @current_scope = Scope.new @current_scope, Scope::TYPE_LOOP, body_tokens # swap current scope with loop scope

        result = nil
        loop_range.each do |i|
          @current_scope.reset
          @sore = i
          result = process
          if result.is_a? ReturnValue
            next if result.value == Token::NEXT
            break
          end
        end

        @current_scope = current_scope # replace current scope

        result if result.is_a?(ReturnValue) && result.value != Token::BREAK
      end

      private

      def loop_range_from_stack!
        if @stack.last&.type == Token::LOOP_ITERATOR
          target = resolve_variable! @stack
          @stack.clear # discard iterator
          validate_type [String, SdArray], target
          range = target.is_a?(String) ? target.each_char : target.values

          Util::Logger.debug Util::Options::DEBUG_2, "loop over #{range.size} values".lpink
        else
          start_index, end_index = loop_end_points_from_stack!
          range = start_index <= end_index ? start_index.upto(end_index) : start_index.downto(end_index)
          Util::Logger.debug Util::Options::DEBUG_2, "loop from #{start_index} to #{end_index}".lpink
        end

        range
      end

      def loop_end_points_from_stack!
        if @stack.empty?
          [0, Float::INFINITY]
        else
          start_index = resolve_variable! @stack
          end_index = resolve_variable! @stack

          validate_type [Numeric], start_index
          validate_type [Numeric], end_index

          [start_index.to_i, end_index.to_i]
        end
      end
    end
  end
end
