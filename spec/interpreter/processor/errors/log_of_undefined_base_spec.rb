require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error when calling log with base 0' do
      tokens = [
        Token.new(Token::PARAMETER, '0', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '10', particle: 'の', sub_type: Token::VAL_NUM),
        Token.new(Token::LOGARITHM),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_unless_bang tokens, Interpreter::Errors::LogOfUndefinedBase
    end

    it 'raises an error when calling log with base 1' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '10', particle: 'の', sub_type: Token::VAL_NUM),
        Token.new(Token::LOGARITHM),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_unless_bang tokens, Interpreter::Errors::LogOfUndefinedBase
    end
  end
end
