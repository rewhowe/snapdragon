require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error when calling 追加する with a non-container' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '追加する', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedContainer
    end

    it 'raises an error when calling 連結する with a non-container (1)' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '「あ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '連結する', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedContainer
    end

    it 'raises an error when calling 連結する with a non-container (2)' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '連結する', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedContainer
    end

    it 'raises an error when calling 抜く with a non-container' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '抜く', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedContainer
    end

    it 'raises an error when calling 全部抜く with a non-container' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '全部抜く', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedContainer
    end

    it 'raises an error when calling 押し込む with a non-container' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '押し込む', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedContainer
    end

    it 'raises an error when calling 先頭を抜き出す with a non-container' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '抜き出す', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedContainer
    end

    it 'raises an error when calling 先頭から押し込む with a non-container' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '先頭から押し込む', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedContainer
    end

    it 'raises an error when calling 先頭を抜き出す with a non-container' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '先頭を抜き出す', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedContainer
    end
  end
end
