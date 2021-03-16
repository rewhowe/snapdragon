require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error on string interpolation with a non-existent property' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「【ホゲの ピヨ】」', sub_type: Token::VAL_STR),
      )
      expect { execute } .to raise_error Interpreter::Errors::PropertyDoesNotExist
    end
  end
end
