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

      def loop_range_from_stack!
        start_index = 0
        end_index = Float::INFINITY

        if @stack.last&.type == Token::LOOP_ITERATOR
          target = resolve_variable! @stack
          @stack.clear # discard iterator
          validate_type [Array, String], target
          end_index = target.length

          range = target.is_a?(String) ? target.each_char : target
        else
          unless @stack.empty?
            start_index = resolve_variable!(@stack).to_i
            end_index = resolve_variable!(@stack).to_i
          end

          range = start_index <= end_index ? start_index.upto(end_index - 1) : start_index.downto(end_index + 1)
        end

        Util::Logger.debug Util::Options::DEBUG_2, "loop from #{start_index} to #{end_index}".lpink

        range
      end
    end
  end
end
