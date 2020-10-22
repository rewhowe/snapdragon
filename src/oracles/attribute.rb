require_relative '../token'
require_relative '../tokenizer/constants'
require_relative 'value'

module Oracles
  class Attribute
    private_class_method :new

    class << self
      def type(attribute)
        return Token::ATTR_LEN  if length? attribute
        return Token::KEY_INDEX if key_index? attribute
        return Token::KEY_NAME  if Value.string? attribute
        Token::KEY_VAR
      end

      def length?(attribute)
        attribute =~ /^((長|なが)さ|(大|おお)きさ|数|かず)$/
      end

      def key_index?(attribute)
        attribute =~ /^([0-9０-９]+)[#{Tokenizer::COUNTER}]目$/
      end
    end
  end
end
