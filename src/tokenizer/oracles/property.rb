require_relative '../../token'
require_relative '../constants'
require_relative 'value'

module Tokenizer
  module Oracles
    class Property
      private_class_method :new

      class << self
        ##
        # NOTE: Property names take precedence over variables with property-like
        # names.
        def type(property)
          return Token::PROP_LEN        if length? property
          return Token::KEY_INDEX       if key_index? property
          return Token::KEY_NAME        if Value.string? property
          return Token::PROP_KEYS       if keys? property
          return Token::PROP_FIRST      if first? property
          return Token::PROP_LAST       if last? property
          return Token::PROP_FIRST_IGAI if other_than_first? property
          return Token::PROP_LAST_IGAI  if other_than_last? property

          type = Value.type property
          return Token::KEY_SORE if type == Token::VAR_SORE
          return Token::KEY_ARE if type == Token::VAR_ARE

          Token::KEY_VAR
        end

        def length?(property)
          property =~ /\A((長|なが)さ|(大|おお)きさ|数|かず)\z/ || (property =~ /\A#{COUNTER}数\z/ && property != 'つ数')
        end

        def keys?(property)
          property == 'キー列'
        end

        def first?(property)
          property == '先頭'
        end

        def last?(property)
          property == '末尾'
        end

        def other_than_first?(property)
          property == '先頭以外'
        end

        def other_than_last?(property)
          property == '末尾以外'
        end

        def key_index?(property)
          property =~ /\A([#{NUMBER}]+)#{COUNTER}目\z/
        end

        def read_only?(property_type)
          [
            Token::PROP_LEN,
            Token::PROP_KEYS,
            Token::PROP_FIRST_IGAI,
            Token::PROP_LAST_IGAI,
          ].include? property_type
        end

        ##
        # Returns true unless the property cannot be iterable. The property may
        # still not be iterable at run time.
        # At the moment, only length is certain to be non-iterable.
        def iterable?(property_type)
          property_type != Token::PROP_LEN
        end

        def valid_string_property?(property_type)
          property_type != Token::PROP_KEYS
        end

        def sanitize(property)
          if key_index? property
            Value.sanitize property.gsub(/#{COUNTER}目\z/, '')
          else
            property
          end
        end
      end
    end
  end
end
