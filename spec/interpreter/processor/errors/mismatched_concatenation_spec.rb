require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error when calling 連結する with differently-typed arguments' do
      tokens = [
        Token.new(Token::PARAMETER, '配列', particle: 'に', sub_type: Token::VAL_ARRAY),
        Token.new(Token::PARAMETER, '「あ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '連結する', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::MismatchedConcatenation
    end
  end
end
