require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error when calling log of 0' do
      tokens = [
        Token.new(Token::PARAMETER, '10', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '0', particle: 'の', sub_type: Token::VAL_NUM),
        Token.new(Token::LOGARITHM),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_unless_bang tokens, Interpreter::Errors::LogOfZero
    end
  end
end
