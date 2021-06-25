module Interpreter
  class Processor
    module TokenProcessors
      def process_debug(_token)
        return if @options[:debug] == Util::Options::DEBUG_OFF

        debug_message = [
          @current_scope.to_s,
          "#{Tokenizer::ID_SORE}: " + Formatter.output(@sore),
          "#{Tokenizer::ID_ARE}: " + Formatter.output(@are),
        ].join "\n"
        Util::Logger.debug Util::Options::DEBUG_3, debug_message.lblue
        exit if peek_next_token&.type == Token::BANG
      end
    end
  end
end
