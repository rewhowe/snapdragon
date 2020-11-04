module Util
  class TokenPrinter
    private_class_method :new

    class << self
      def print_all(lexer, options)
        tokens_from(lexer, options).each do |token|
          puts [token.type.to_s.blue, token.content.to_s, token.sub_type.to_s.blue].join ' '
        end
      rescue Tokenizer::Errors::BaseError => e
        raise e if options[:debug] # show full stack trace if in debug mode
        puts e.message             # otherwise just display the error message
        exit
      end

      private

      def tokens_from(lexer)
        [].tap do |tokens|
          loop do
            token = lexer.next_token
            break if token.nil?
            tokens << token
          end
        end
      end
    end
  end
end
