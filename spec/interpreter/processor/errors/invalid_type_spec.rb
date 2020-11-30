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
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error when calling 投げる with a non-string' do
      mock_lexer(
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '投げる', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      )
      expect { execute } .to raise_error Interpreter::Errors::InvalidType
    end

    it 'raises an error when calling 繋ぐ with a non-container (1)' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '「あ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '繋ぐ', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error when calling 繋ぐ with a non-container (2)' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '繋ぐ', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error when calling 抜く with a non-container' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '抜く', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error when calling 抜く with a string and non-string' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'から', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '抜く', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error when calling 全部抜く with a non-container' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '全部抜く', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error when calling 全部抜く with a string and non-string' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'から', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '全部抜く', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error when calling 押し込む with a non-container' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '押し込む', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error when calling 先頭を引き出す with a non-container' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '引き出す', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error when calling 先頭から押し込む with a non-container' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '先頭から押し込む', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error when calling 先頭から押し込む with a strign and non-string' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '先頭から押し込む', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error when calling 先頭を引き出す with a non-container' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '先頭を引き出す', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error on 足す with non-numbers (1)' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '足す', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error on 足す with non-numbers (2)' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '「あ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '足す', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error on 引く with non-numbers (1)' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'から', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '引く', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error on 引く with non-numbers (2)' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '「あ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '引く', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error on 掛ける with non-numbers (1)' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '掛ける', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error on 掛ける with non-numbers (2)' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '「あ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '掛ける', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error on 割る with non-numbers (1)' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'で', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '割る', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error on 割る with non-numbers (2)' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '「あ」', particle: 'で', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '割る', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error on 割った余りを求める with non-numbers (1)' do
      tokens = [
        Token.new(Token::PARAMETER, '「あ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '1', particle: 'で', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '割った余りを求める', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end

    it 'raises an error on 割った余りを求める with non-numbers (2)' do
      tokens = [
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '「あ」', particle: 'で', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '割った余りを求める', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG, '!'),
      ]
      expect_error_only_if_bang tokens, Interpreter::Errors::InvalidType
    end
  end
end
