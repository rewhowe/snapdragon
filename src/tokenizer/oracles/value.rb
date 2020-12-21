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
        def type(value)
          return Token::VAL_NUM if number? value
          return Token::VAL_STR if string? value

          case value
          when /^それ$/              then Token::VAR_SORE # special
          when /^あれ$/              then Token::VAR_ARE  # special
          when /^配列$/              then Token::VAL_ARRAY # TODO: (v1.1.0) add 連想配列
          when /^(真|肯定|はい|正)$/ then Token::VAL_TRUE
          when /^(偽|否定|いいえ)$/  then Token::VAL_FALSE
          when /^(無(い|し)?|ヌル)$/ then Token::VAL_NULL
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity

        def number?(value)
          value =~ /^(-|ー)?([#{NUMBER}]+(\.|．)[#{NUMBER}]+|[#{NUMBER}]+)$/
        end

        def string?(value)
          value =~ /^「.*」$/m
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
