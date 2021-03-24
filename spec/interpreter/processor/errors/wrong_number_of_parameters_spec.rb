require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error when string formatting with too few parameters' do
      mock_lexer(
        Token.new(Token::PARAMETER, '「〇〇」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FORMAT_STRING, sub_type: Token::FUNC_BUILT_IN),
      )
      expect { execute } .to raise_error Interpreter::Errors::WrongNumberOfParameters
    end

    it 'raises an error when string formatting with too many parameters' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '3', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),
        Token.new(Token::PARAMETER, '「〇〇」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FORMAT_STRING, sub_type: Token::FUNC_BUILT_IN),
      )
      expect { execute } .to raise_error Interpreter::Errors::WrongNumberOfParameters
    end
  end
end
