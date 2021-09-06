require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error when a string cannot be cast to a number' do
      mock_lexer(
        Token.new(Token::PARAMETER, '「ホゲ」', particle: 'で', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::CAST_TO_N, sub_type: Token::FUNC_BUILT_IN),
      )
      expect { execute } .to raise_error Interpreter::Errors::CastFailure
    end

    it 'raises an error when a string cannot be cast to an integer' do
      mock_lexer(
        Token.new(Token::PARAMETER, '「ホゲ」', particle: 'で', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::CAST_TO_I, sub_type: Token::FUNC_BUILT_IN),
      )
      expect { execute } .to raise_error Interpreter::Errors::CastFailure
    end
  end
end
