require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'

require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'error handling' do
  include_context 'processor'

  describe '#execute' do
    it 'raises an error on 足す with non-numbers (1)' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '足す'),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedNumber
    end

    it 'raises an error on 足す with non-numbers (2)' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '「あ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '足す'),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedNumber
    end

    it 'raises an error on 引く with non-numbers (1)' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'から', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '引く'),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedNumber
    end

    it 'raises an error on 引く with non-numbers (2)' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '「あ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '引く'),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedNumber
    end

    it 'raises an error on 掛ける with non-numbers (1)' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '掛ける'),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedNumber
    end

    it 'raises an error on 掛ける with non-numbers (2)' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '「あ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '掛ける'),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedNumber
    end

    it 'raises an error on 割る with non-numbers (1)' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'で', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '割る'),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedNumber
    end

    it 'raises an error on 割る with non-numbers (2)' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '「あ」', particle: 'で', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '割る'),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedNumber
    end

    it 'raises an error on 割った余りを求める with non-numbers (1)' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'で', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '割った余りを求める'),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedNumber
    end

    it 'raises an error on 割った余りを求める with non-numbers (2)' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '「あ」', particle: 'で', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '割った余りを求める'),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::ExpectedNumber
    end
  end
end
