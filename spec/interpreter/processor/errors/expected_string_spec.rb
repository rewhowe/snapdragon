require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error when calling 言う with a non-string' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '言う', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedString
    end

    it 'raises an error when calling 投げる with a non-string' do
      mock_lexer(
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '投げる', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      )
      expect { execute } .to raise_error Interpreter::Errors::ExpectedString
    end

    it 'raises an error when calling 追加する with a string and non-string' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '追加する', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedString
    end

    it 'raises an error when calling 抜く with a string and non-string' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'から', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '抜く', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedString
    end

    it 'raises an error when calling 全部抜く with a string and non-string' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'から', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '全部抜く', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedString
    end

    it 'raises an error when calling 先頭から押し込む with a strign and non-string' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '先頭から押し込む', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedString
    end
  end
end
