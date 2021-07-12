require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error when accessing an invalid numeric property' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '長さ', sub_type: Token::PROP_LEN),
      )
      expect { execute } .to raise_error Interpreter::Errors::InvalidNumericProperty
    end
  end
end
