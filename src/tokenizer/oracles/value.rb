require_relative '../../token'

module Tokenizer
  module Oracles
    class Value
      private_class_method :new

      class << self
        # Returns true if value is a primitive or a reserved keyword variable.
        def value?(value)
          !type(value).nil?
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Layout/ExtraSpacing
        def type(value)
          return Token::VAL_NUM if number? value
          return Token::VAL_STR if string? value

          case value
          when ID_SORE                 then Token::VAR_SORE
          when ID_ARE                  then Token::VAR_ARE
          when /\A(連想)?配列\z/       then Token::VAL_ARRAY
          when /\A(真|肯定|はい|正)\z/ then Token::VAL_TRUE
          when /\A(偽|否定|いいえ)\z/  then Token::VAL_FALSE
          when /\A(無(い|し)?|ヌル)\z/ then Token::VAL_NULL
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Layout/ExtraSpacing

        def number?(value)
          value =~ /\A(-|ー)?([#{NUMBER}]+(\.|．)[#{NUMBER}]+|[#{NUMBER}]+)\z/
        end

        def string?(value)
          value =~ /\A「.*」\z/m
        end

        def special?(value)
          [ID_SORE, ID_ARE, ID_ARGV, ID_ERR].include? value
        end

        def sanitize(value)
          if string? value
            # Strips leading and trailing whitespace and newlines within the string.
            # Whitespace at the beginning and ending of the string are not stripped.
            value.gsub(/[#{WHITESPACE}]*\n[#{WHITESPACE}]*/, '')
          elsif number? value
            value.tr 'ー．０-９', '-.0-9'
          else
            value
          end
        end
      end
    end
  end
end
