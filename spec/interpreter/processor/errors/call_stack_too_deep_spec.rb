require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error on (probable) infinite recursion' do
      tokens = [
        Token.new(Token::FUNCTION_DEF, 'ほげる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::FUNCTION_CALL, 'ほげる'),
        Token.new(Token::BANG, '!'),
        Token.new(Token::PARAMETER, '無', particle: 'を', sub_type: Token::VAL_NULL), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::FUNCTION_CALL, 'ほげる'),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::CallStackTooDeep
    end
  end
end