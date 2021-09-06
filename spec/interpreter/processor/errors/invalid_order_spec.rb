require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error when sorting with an invalid order' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '「フガ」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::SORT, sub_type: Token::FUNC_BUILT_IN),
      )
      expect { execute } .to raise_error Interpreter::Errors::InvalidOrder
    end
  end
end
