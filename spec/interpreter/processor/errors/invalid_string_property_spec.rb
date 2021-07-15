require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error when assigning to an invalid string property' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '「ふが」', sub_type: Token::KEY_NAME),
        Token.new(Token::RVALUE, '「あ」', sub_type: Token::VAL_STR),
      )
      expect { execute } .to raise_error Interpreter::Errors::InvalidStringProperty
    end

    it 'raises an error when assigning to an out-of-bounds string index' do
      {
        '「」' => '1', # 0th index of empty string
        '「あ」' => '10', # 9th index of length-1 string
      }.each do |string, index|
        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, string, sub_type: Token::VAL_STR),
          Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
          Token.new(Token::ASSIGNMENT, index, sub_type: Token::KEY_INDEX),
          Token.new(Token::RVALUE, '「あ」', sub_type: Token::VAL_STR),
        )
        expect { execute } .to raise_error Interpreter::Errors::InvalidStringProperty
      end
    end

    it 'raises an error when accessing an invalid string property' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, 'キー列', sub_type: Token::PROP_KEYS),
      )
      expect { execute } .to raise_error Interpreter::Errors::InvalidStringProperty
    end
  end
end
