require './src/tokenizer/lexer.rb'
require './src/tokenizer/token.rb'
require './spec/contexts/lexer.rb'

include Tokenizer

RSpec.describe Lexer, 'built-ins' do
  include_context 'lexer'

  describe '#next_token' do
    it 'tokenizes built-in function print' do
      mock_reader(
        "「言葉」を 言う\n" \
        "「こんにちは」と 言う\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '「言葉」', Token::VAR_STR], [Token::FUNCTION_CALL, '言う'],
        [Token::PARAMETER, '「こんにちは」', Token::VAR_STR], [Token::FUNCTION_CALL, '言う'],
      )
    end

    it 'tokenizes built-in function log' do
      mock_reader(
        "「メッセージ」を ログする\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '「メッセージ」', Token::VAR_STR], [Token::FUNCTION_CALL, 'ログする'],
      )
    end

    it 'tokenizes built-in function std out' do
      mock_reader(
        "「メッセージ」を 表示する\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '「メッセージ」', Token::VAR_STR], [Token::FUNCTION_CALL, '表示する'],
      )
    end

    it 'tokenizes built-in function raise' do
      mock_reader(
        "「エラー」を 投げる\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '「エラー」', Token::VAR_STR], [Token::FUNCTION_CALL, '投げる'],
      )
    end

    it 'tokenizes built-in function append' do
      mock_reader(
        "配列に 「追加対象」を 追加する\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '配列', Token::VAR_ARRAY],
        [Token::PARAMETER, '「追加対象」', Token::VAR_STR],
        [Token::FUNCTION_CALL, '追加する'],
      )
    end

    it 'tokenizes built-in function concatenate' do
      mock_reader(
        "配列に 配列を 連結する\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '配列', Token::VAR_ARRAY],
        [Token::PARAMETER, '配列', Token::VAR_ARRAY],
        [Token::FUNCTION_CALL, '連結する'],
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
        [Token::VARIABLE, '1', Token::VAR_NUM], [Token::COMMA],
        [Token::VARIABLE, '2', Token::VAR_NUM], [Token::COMMA],
        [Token::VARIABLE, '2', Token::VAR_NUM], [Token::COMMA],
        [Token::VARIABLE, '2', Token::VAR_NUM],
        [Token::ARRAY_CLOSE],
        [Token::PARAMETER, 'ほげ', Token::VARIABLE],
        [Token::PARAMETER, '2', Token::VAR_NUM],
        [Token::FUNCTION_CALL, '抜く'],
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
        [Token::VARIABLE, '1', Token::VAR_NUM], [Token::COMMA],
        [Token::VARIABLE, '2', Token::VAR_NUM], [Token::COMMA],
        [Token::VARIABLE, '2', Token::VAR_NUM], [Token::COMMA],
        [Token::VARIABLE, '2', Token::VAR_NUM],
        [Token::ARRAY_CLOSE],
        [Token::PARAMETER, 'ほげ', Token::VARIABLE],
        [Token::PARAMETER, '2', Token::VAR_NUM],
        [Token::FUNCTION_CALL, '全部抜く'],
      )
    end

    it 'tokenizes built-in function push' do
      mock_reader(
        "配列に 1を 押し込む\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '配列', Token::VAR_ARRAY],
        [Token::PARAMETER, '1', Token::VAR_NUM],
        [Token::FUNCTION_CALL, '押し込む'],
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
        [Token::VARIABLE, '1', Token::VAR_NUM], [Token::COMMA],
        [Token::VARIABLE, '2', Token::VAR_NUM], [Token::COMMA],
        [Token::VARIABLE, '3', Token::VAR_NUM],
        [Token::ARRAY_CLOSE],
        [Token::PARAMETER, 'ほげ', Token::VARIABLE], [Token::FUNCTION_CALL, '抜き出す'],
      )
    end

    it 'tokenizes built-in function unshift' do
      mock_reader(
        "配列に 1を 先頭から押し込む\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '配列', Token::VAR_ARRAY],
        [Token::PARAMETER, '1', Token::VAR_NUM],
        [Token::FUNCTION_CALL, '先頭から押し込む'],
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
        [Token::VARIABLE, '1', Token::VAR_NUM], [Token::COMMA],
        [Token::VARIABLE, '2', Token::VAR_NUM], [Token::COMMA],
        [Token::VARIABLE, '3', Token::VAR_NUM],
        [Token::ARRAY_CLOSE],
        [Token::PARAMETER, 'ほげ', Token::VARIABLE], [Token::FUNCTION_CALL, '先頭を抜き出す'],
      )
    end

    it 'tokenizes built-in function add' do
      mock_reader(
        "1に 1を 足す\n" \
        "1を 足す\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '1', Token::VAR_NUM],
        [Token::PARAMETER, '1', Token::VAR_NUM],
        [Token::FUNCTION_CALL, '足す'],
        [Token::PARAMETER, '1', Token::VAR_NUM], [Token::FUNCTION_CALL, '足す'],
      )
    end

    it 'tokenizes built-in function subtract' do
      mock_reader(
        "1から 1を 引く\n" \
        "1を 引く\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '1', Token::VAR_NUM],
        [Token::PARAMETER, '1', Token::VAR_NUM],
        [Token::FUNCTION_CALL, '引く'],
        [Token::PARAMETER, '1', Token::VAR_NUM], [Token::FUNCTION_CALL, '引く'],
      )
    end

    it 'tokenizes built-in function multiply' do
      mock_reader(
        "2に 3を 掛ける\n" \
        "5を 掛ける\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '2', Token::VAR_NUM],
        [Token::PARAMETER, '3', Token::VAR_NUM],
        [Token::FUNCTION_CALL, '掛ける'],
        [Token::PARAMETER, '5', Token::VAR_NUM], [Token::FUNCTION_CALL, '掛ける'],
      )
    end

    it 'tokenizes built-in function divide' do
      mock_reader(
        "10を 2で 割る\n" \
        "2.5で 割る\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '10', Token::VAR_NUM],
        [Token::PARAMETER, '2', Token::VAR_NUM],
        [Token::FUNCTION_CALL, '割る'],
        [Token::PARAMETER, '2.5', Token::VAR_NUM], [Token::FUNCTION_CALL, '割る'],
      )
    end

    it 'tokenizes built-in function modulus' do
      mock_reader(
        "7を 3で 割った余りを求める\n" \
        "10で 割った余りを求める\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '7', Token::VAR_NUM],
        [Token::PARAMETER, '3', Token::VAR_NUM],
        [Token::FUNCTION_CALL, '割った余りを求める'],
        [Token::PARAMETER, '10', Token::VAR_NUM], [Token::FUNCTION_CALL, '割った余りを求める'],
      )
    end
  end
end
