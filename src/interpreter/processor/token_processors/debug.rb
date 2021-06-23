module Interpreter
  class Processor
    module TokenProcessors
      def process_debug(_token)
        return if @options[:debug] == Util::Options::DEBUG_OFF

        debug_message = [
          @current_scope.to_s,
          'それ: ' + Formatter.output(@sore),
          'あれ: ' + Formatter.output(@are),
        ].join "\n"
        Util::Logger.debug Util::Options::DEBUG_3, debug_message.lblue
        exit if peek_next_token&.type == Token::BANG
      end
    end
  end
end
