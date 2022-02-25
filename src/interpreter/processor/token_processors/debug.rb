module Interpreter
  class Processor
    module TokenProcessors
      def process_debug(_token)
        Util::Logger.debug(Util::Options::DEBUG_3) do
          [
            @current_scope.to_s,
            "#{Tokenizer::ID_SORE}: " + Formatter.output(@sore),
            "#{Tokenizer::ID_ARE}: " + Formatter.output(@are),
          ].join("\n").lblue
        end

        exit if peek_next_token&.type == Token::BANG
      end
    end
  end
end
