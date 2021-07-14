module Interpreter
  class Processor
    module TokenProcessors
      def process_logarithm(_token)
        (base, argument) = resolve_parameters_from_stack!

        validate_type [Numeric], base
        validate_type [Numeric], argument

        Util::Logger.debug Util::Options::DEBUG_2, "log base #{base} of #{argument}".lpink

        return @sore = nil if base.zero? || argument.zero?

        @sore = Math.log argument, base
      end
    end
  end
end
