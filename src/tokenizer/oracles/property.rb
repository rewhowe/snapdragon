require_relative '../../token'
require_relative '../constants'
require_relative 'value'

module Tokenizer
  module Oracles
    class Property
      private_class_method :new

      # Property flags:
      READ_ONLY  = 0b0
      READ_WRITE = 0b1
      SINGULAR   = 0b00
      ITERABLE   = 0b10
      # Valid property owners:
      ARRAY_OK   = 0b100
      STRING_OK  = 0b1000
      NUMBER_OK  = 0b10000

      PROPERTIES = {
        # Defined properties
        Token::PROP_LEN        => READ_ONLY  | SINGULAR | ARRAY_OK | STRING_OK,
        Token::PROP_KEYS       => READ_ONLY  | ITERABLE | ARRAY_OK | STRING_OK,
        Token::PROP_FIRST      => READ_WRITE | ITERABLE | ARRAY_OK | STRING_OK,
        Token::PROP_LAST       => READ_WRITE | ITERABLE | ARRAY_OK | STRING_OK,
        Token::PROP_FIRST_IGAI => READ_ONLY  | ITERABLE | ARRAY_OK | STRING_OK,
        Token::PROP_LAST_IGAI  => READ_ONLY  | ITERABLE | ARRAY_OK | STRING_OK,
        # Calculated properties
        Token::PROP_EXP        => READ_ONLY  | SINGULAR | NUMBER_OK,
        Token::PROP_EXP_SORE   => READ_ONLY  | SINGULAR | NUMBER_OK,
        Token::PROP_EXP_ARE    => READ_ONLY  | SINGULAR | NUMBER_OK,
        Token::PROP_ROOT       => READ_ONLY  | SINGULAR | NUMBER_OK,
        Token::PROP_ROOT_SORE  => READ_ONLY  | SINGULAR | NUMBER_OK,
        Token::PROP_ROOT_ARE   => READ_ONLY  | SINGULAR | NUMBER_OK,
        # Direct access
        Token::KEY_INDEX       => READ_WRITE | ITERABLE | ARRAY_OK | STRING_OK, # Numeric index
        Token::KEY_NAME        => READ_WRITE | ITERABLE | ARRAY_OK | STRING_OK, # String or numeric string index
        Token::KEY_SORE        => READ_WRITE | ITERABLE | ARRAY_OK | STRING_OK,
        Token::KEY_ARE         => READ_WRITE | ITERABLE | ARRAY_OK | STRING_OK,
        Token::KEY_VAR         => READ_WRITE | ITERABLE | ARRAY_OK | STRING_OK,
      }.freeze

      class << self
        ##
        # NOTE: Property names take precedence over variables with property-like
        # names.
        def type(property)
          PROPERTIES.keys.each do |sub_type|
            return sub_type if send "#{sub_type}?", property
          end
        end

        def writable?(property_type)
          (PROPERTIES[property_type] & READ_WRITE).nonzero?
        end

        def iterable?(property_type)
          (PROPERTIES[property_type] & ITERABLE).nonzero?
        end

        ##
        # A token with one of the following sub types may have properties.
        def valid_property_owner?(property_owner_type)
          [
            Token::VARIABLE,
            Token::VAR_SORE,
            Token::VAR_ARE,
            Token::VAL_STR,
            Token::VAL_NUM,
          ].include? property_owner_type
        end

        ##
        # A property owner with one of the following sub types may have its
        # properties modified.
        def mutable_property_owner?(property_owner_type)
          [Token::VARIABLE, Token::VAR_SORE, Token::VAR_ARE].include? property_owner_type
        end

        ##
        # Properties which may be the same as their possessives.
        def can_reference_self?(property_type)
          [
            Token::PROP_EXP,
            Token::PROP_EXP_SORE,
            Token::PROP_EXP_ARE,
            Token::PROP_ROOT,
            Token::PROP_ROOT_SORE,
            Token::PROP_ROOT_ARE,
          ].include? property_type
        end

        def valid_property_and_owner?(property_type, property_owner_type)
          validity_flag = {
            Token::VAL_STR => STRING_OK,
            Token::VAL_NUM => NUMBER_OK,
            # No ARRAY_OK because array primitives yield nothing useful
          }[property_owner_type]

          return true unless validity_flag # cannot be determined until runtime

          (PROPERTIES[property_type] & validity_flag).nonzero?
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/PerceivedComplexity
        def sanitize(property)
          if key_index? property
            Value.sanitize property.gsub(/#{COUNTER}目\z/, '')
          elsif prop_exp?(property) || prop_root?(property)
            property = property.tr '乗根', ''
            { '自' => '2', '平方' => '2' }[property] || Value.sanitize(property)
          elsif prop_exp_sore?(property) || prop_root_sore?(property)
            ID_SORE
          elsif prop_exp_are?(property) || prop_root_are?(property)
            ID_ARE
          else
            property
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/PerceivedComplexity

        private

        def prop_len?(property)
          property =~ /\A((長|なが)さ|(大|おお)きさ|数|かず)\z/ ||
            (property =~ /\A#{COUNTER}数\z/ && property != 'つ数')
        end

        def prop_keys?(property)
          %w[キー列 インデックス].include? property
        end

        def prop_first?(property)
          property == '先頭'
        end

        def prop_last?(property)
          property == '末尾'
        end

        def prop_first_igai?(property)
          property == '先頭以外'
        end

        def prop_last_igai?(property)
          property == '末尾以外'
        end

        def prop_exp?(property)
          property =~ /\A([#{NUMBER}]+|自)乗\z/ || property == '平方'
        end

        def prop_exp_sore?(property)
          property == 'その乗'
        end

        def prop_exp_are?(property)
          property == 'あの乗'
        end

        def prop_root?(property)
          property =~ /\A([#{NUMBER}]+|自)乗根\z/ || property == '平方根'
        end

        def prop_root_sore?(property)
          property == 'その乗根'
        end

        def prop_root_are?(property)
          property == 'あの乗根'
        end

        def key_index?(property)
          property =~ /\A[#{NUMBER}]+#{COUNTER}目\z/
        end

        def key_name?(property)
          Value.string? property
        end

        def key_sore?(property)
          Value.type(property) == Token::VAR_SORE
        end

        def key_are?(property)
          Value.type(property) == Token::VAR_ARE
        end

        def key_var?(_property)
          true
        end
      end
    end
  end
end
