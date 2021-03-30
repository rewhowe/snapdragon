require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error when number formatting with an invalid format' do
      mock_lexer(
        Token.new(Token::PARAMETER, '「〇（N桁）」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FORMAT, sub_type: Token::FUNC_BUILT_IN),
      )
      expect { execute } .to raise_error Interpreter::Errors::InvalidFormat
    end

    it 'raises an error when number rounding with an invalid format' do
      mock_lexer(
        Token.new(Token::PARAMETER, '46.49', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '「N桁」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ROUND, sub_type: Token::FUNC_BUILT_IN),
      )
      expect { execute } .to raise_error Interpreter::Errors::InvalidFormat
    end
  end
end
