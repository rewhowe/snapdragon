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
          {
            Token::PROP_LEN        => :length?,
            Token::PROP_KEYS       => :keys?,
            Token::PROP_FIRST      => :first?,
            Token::PROP_LAST       => :last?,
            Token::PROP_FIRST_IGAI => :other_than_first?,
            Token::PROP_LAST_IGAI  => :other_than_last?,
            Token::KEY_INDEX       => :key_index?,
            Token::KEY_NAME        => :key_name?,
          }.each do |sub_type, method|
            return sub_type if send method, property
          end

          type = Value.type property
          return Token::KEY_SORE if type == Token::VAR_SORE
          return Token::KEY_ARE if type == Token::VAR_ARE

          Token::KEY_VAR
        end

        def length?(property)
          property =~ /\A((長|なが)さ|(大|おお)きさ|数|かず)\z/ ||
            (property =~ /\A#{COUNTER}数\z/ && property != 'つ数')
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

        def key_name?(property)
          Value.string? property
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
