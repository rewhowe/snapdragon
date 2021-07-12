module Interpreter
  class Processor
    module TokenProcessors
      def process_logarithm(token)
        # TODO: move this method to processor and rename to resolve_arguments_from_stack!
        (base, argument) = resolve_function_arguments_from_stack!

        validate_type [Numeric], base
        validate_type [Numeric], argument

        Util::Logger.debug Util::Options::DEBUG_2, "log base #{base} of #{argument}".lpink

        if base.zero? || argument.zero?
          @sore = nil
        else
          @sore = Math.log argument, base
        end
      end
    end
  end
end
