require_relative '../token'
require_relative '../tokenizer/lexer.rb'
require_relative 'value'

module Oracles
  class Attribute
    private_class_method :new

    class << self
      def type(attribute)
        return Token::ATTR_LEN  if length? attribute
        return Token::KEY_INDEX if key_index? attribute
        # TODO: remove Oracles::?
        return Token::KEY_NAME  if Oracles::Value.string? attribute
        Token::KEY_VAR
      end

      def length?(attribute)
        attribute =~ /^((長|なが)さ|(大|おお)きさ|数|かず)$/
      end

      def key_index?(attribute)
        attribute =~ /^([0-9０-９]+)[#{Lexer::COUNTER}]目$/
      end
    end
  end
end
