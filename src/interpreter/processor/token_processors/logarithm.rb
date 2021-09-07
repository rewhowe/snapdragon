module Interpreter
  class Processor
    module TokenProcessors
      # QoL note: returns the rounded log if it gives the original argument when
      # raising the same base
      def process_logarithm(_token)
        (base, argument) = resolve_parameters_from_stack!

        validate_type [Numeric], base
        validate_type [Numeric], argument

        Util::Logger.debug(Util::Options::DEBUG_2) { Util::I18n.t('interpreter.log', base, argument).lpink }

        should_suppress_error = !next_token_if(Token::BANG).nil?

        begin
          raise Errors::LogOfUndefinedBase, base if [0, 1].include? base
          raise Errors::LogOfZero if argument.zero?

          log = Math.log argument, base
          log = log.round if base**log.round == argument
          @sore = log
        rescue
          raise unless should_suppress_error
          @sore = nil
        end
      end
    end
  end
end
