require './src/token'
require './src/tokenizer/built_ins'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error on division by zero' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '0', particle: 'で', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::DIVIDE, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_unless_bang tokens, Interpreter::Errors::DivisionByZero
    end

    it 'raises an error on modulus by zero' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '0', particle: 'で', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::MODULUS, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_unless_bang tokens, Interpreter::Errors::DivisionByZero
    end
  end
end
