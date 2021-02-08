require './src/token'
require './src/tokenizer/built_ins'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error when calling 繋ぐ with differently-typed arguments' do
      tokens = [
        Token.new(Token::PARAMETER, '配列', particle: 'に', sub_type: Token::VAL_ARRAY),
        Token.new(Token::PARAMETER, '「あ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::CONCATENATE, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_unless_bang tokens, Interpreter::Errors::MismatchedConcatenation
    end
  end
end
