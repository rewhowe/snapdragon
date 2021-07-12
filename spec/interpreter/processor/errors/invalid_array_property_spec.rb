require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error when accessing an invalid string property' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '2', sub_type: Token::PROP_EXP),
      )
      expect { execute } .to raise_error Interpreter::Errors::InvalidArrayProperty
    end
  end
end
