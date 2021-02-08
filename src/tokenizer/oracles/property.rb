require_relative '../../token'
require_relative '../constants'
require_relative 'value'

module Tokenizer
  module Oracles
    class Property
      private_class_method :new

      class << self
        def type(property)
          return Token::PROP_LEN  if length? property
          return Token::KEY_INDEX if key_index? property
          return Token::KEY_NAME  if Value.string? property
          Token::KEY_VAR
        end

        def length?(property)
          property =~ /\A((長|なが)さ|(大|おお)きさ|数|かず)\z/ || (property =~ /\A#{COUNTER}数\z/ && property != 'つ数')
        end

        def key_index?(property)
          property =~ /\A([#{NUMBER}]+)#{COUNTER}目\z/
        end
      end
    end
  end
end
