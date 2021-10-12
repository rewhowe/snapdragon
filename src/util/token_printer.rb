module Util
  class TokenPrinter
    private_class_method :new

    class << self
      def print_all(lexer)
        loop do
          token = lexer.next_token

          break if token.nil?

          puts [token.type.to_s.blue, token.content.to_s, token.sub_type.to_s.blue].join ' '
        end
      end
    end
  end
end
