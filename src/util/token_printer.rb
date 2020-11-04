module Util
  class TokenPrinter
    private_class_method :new

    class << self
      def print_all(lexer)
        tokens_from(lexer).each do |token|
          puts [token.type.to_s.blue, token.content.to_s, token.sub_type.to_s.blue].join ' '
        end
      end

      private

      def tokens_from(lexer)
        [].tap do |tokens|
          loop do
            begin
              token = lexer.next_token
              break if token.nil?
              tokens << token
            rescue Tokenizer::Errors::BaseError => e
              raise e if options[:debug]
              puts e.message
              exit
            end
          end
        end
      end
    end
  end
end
