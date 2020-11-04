require './src/token'
require './src/tokenizer/lexer'
require './spec/contexts/lexer'

include Tokenizer

RSpec.describe Lexer, 'built-ins' do
  include_context 'lexer'

  describe '#next_token' do
    it 'tokenizes built-in stdout' do
      mock_reader(
        "「言葉」を 言う\n" \
        "「こんにちは」と 言う\n" \
        "「メッセージ」を 表示する\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '「言葉」', Token::VAL_STR], [Token::FUNCTION_CALL, '言う', Token::FUNC_BUILT_IN],
        [Token::PARAMETER, '「こんにちは」', Token::VAL_STR], [Token::FUNCTION_CALL, '言う', Token::FUNC_BUILT_IN],
        [Token::PARAMETER, '「メッセージ」', Token::VAL_STR], [Token::FUNCTION_CALL, '表示する', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function debug' do
      mock_reader(
        "それを ポイ捨てる\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, 'それ', Token::VAR_SORE], [Token::FUNCTION_CALL, 'ポイ捨てる', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function raise' do
      mock_reader(
        "「エラー」を 投げる\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '「エラー」', Token::VAL_STR], [Token::FUNCTION_CALL, '投げる', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function append' do
      mock_reader(
        "配列に 「追加対象」を 追加する\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '配列', Token::VAL_ARRAY],
        [Token::PARAMETER, '「追加対象」', Token::VAL_STR],
        [Token::FUNCTION_CALL, '追加する', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function concatenate' do
      mock_reader(
        "配列に 配列を 連結する\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '配列', Token::VAL_ARRAY],
        [Token::PARAMETER, '配列', Token::VAL_ARRAY],
        [Token::FUNCTION_CALL, '連結する', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function remove' do
      mock_reader(
        "ほげは 1、2、2、2\n" \
        "ほげから 2を 抜く\n"
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::RVALUE, '1', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '2', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '2', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '2', Token::VAL_NUM],
        [Token::ARRAY_CLOSE],
        [Token::PARAMETER, 'ほげ', Token::VARIABLE],
        [Token::PARAMETER, '2', Token::VAL_NUM],
        [Token::FUNCTION_CALL, '抜く', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function remove all' do
      mock_reader(
        "ほげは 1、2、2、2\n" \
        "ほげから 2を 全部抜く\n"
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::RVALUE, '1', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '2', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '2', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '2', Token::VAL_NUM],
        [Token::ARRAY_CLOSE],
        [Token::PARAMETER, 'ほげ', Token::VARIABLE],
        [Token::PARAMETER, '2', Token::VAL_NUM],
        [Token::FUNCTION_CALL, '全部抜く', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function push' do
      mock_reader(
        "配列に 1を 押し込む\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '配列', Token::VAL_ARRAY],
        [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, '押し込む', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function pop' do
      mock_reader(
        "ほげは 1、2、3\n" \
        "ほげから 抜き出す\n"
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::RVALUE, '1', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '2', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '3', Token::VAL_NUM],
        [Token::ARRAY_CLOSE],
        [Token::PARAMETER, 'ほげ', Token::VARIABLE], [Token::FUNCTION_CALL, '抜き出す', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function unshift' do
      mock_reader(
        "配列に 1を 先頭から押し込む\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '配列', Token::VAL_ARRAY],
        [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, '先頭から押し込む', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function shift' do
      mock_reader(
        "ほげは 1、2、3\n" \
        "ほげから 先頭を抜き出す\n" \
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::RVALUE, '1', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '2', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '3', Token::VAL_NUM],
        [Token::ARRAY_CLOSE],
        [Token::PARAMETER, 'ほげ', Token::VARIABLE], [Token::FUNCTION_CALL, '先頭を抜き出す', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function add' do
      mock_reader(
        "1に 1を 足す\n" \
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, '足す', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function subtract' do
      mock_reader(
        "1から 1を 引く\n" \
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, '引く', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function multiply' do
      mock_reader(
        "2に 3を 掛ける\n" \
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '2', Token::VAL_NUM],
        [Token::PARAMETER, '3', Token::VAL_NUM],
        [Token::FUNCTION_CALL, '掛ける', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function divide' do
      mock_reader(
        "10を 2で 割る\n" \
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '10', Token::VAL_NUM],
        [Token::PARAMETER, '2', Token::VAL_NUM],
        [Token::FUNCTION_CALL, '割る', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function modulus' do
      mock_reader(
        "7を 3で 割った余りを求める\n" \
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '7', Token::VAL_NUM],
        [Token::PARAMETER, '3', Token::VAL_NUM],
        [Token::FUNCTION_CALL, '割った余りを求める', Token::FUNC_BUILT_IN],
      )
    end

    it 'supplies implicit それ for math built-ins' do
      mock_reader(
        "それは 1\n" \
        "1を 足す\n" \
        "1を 引く\n" \
        "1を 掛ける\n" \
        "1で 割る\n" \
        "1で 割った余りを求める\n"
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'それ', Token::VAR_SORE], [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::PARAMETER, 'それ', Token::VAR_SORE], [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, '足す', Token::FUNC_BUILT_IN],
        [Token::PARAMETER, 'それ', Token::VAR_SORE], [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, '引く', Token::FUNC_BUILT_IN],
        [Token::PARAMETER, 'それ', Token::VAR_SORE], [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, '掛ける', Token::FUNC_BUILT_IN],
        [Token::PARAMETER, 'それ', Token::VAR_SORE], [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, '割る', Token::FUNC_BUILT_IN],
        [Token::PARAMETER, 'それ', Token::VAR_SORE], [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, '割った余りを求める', Token::FUNC_BUILT_IN],
      )
    end
  end
end
