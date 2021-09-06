require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error on string interpolation with a non-existent variable' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「【フガ】」', sub_type: Token::VAL_STR),
      )
      expect { execute } .to raise_error Interpreter::Errors::VariableDoesNotExist
    end

    it 'raises an error on string interpolation with a non-existent possessive' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「【フガの 長さ】」', sub_type: Token::VAL_STR),
      )
      expect { execute } .to raise_error Interpreter::Errors::VariableDoesNotExist
    end
  end
end
