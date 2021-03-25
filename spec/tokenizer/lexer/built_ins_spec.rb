require './src/token'
require './src/tokenizer/built_ins'
require './src/tokenizer/lexer'
require './spec/contexts/lexer'

include Tokenizer

RSpec.describe Lexer, 'built-ins' do
  include_context 'lexer'

  describe '#next_token' do
    # Output
    ############################################################################

    it 'tokenizes built-in stdout' do
      mock_reader(
        "「言葉」を 言う\n" \
        "「こんにちは」と 言う\n" \
        "「メッセージ」を 表示する\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '「言葉」', Token::VAL_STR],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::PRINT, Token::FUNC_BUILT_IN],
        [Token::PARAMETER, '「こんにちは」', Token::VAL_STR],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::PRINT, Token::FUNC_BUILT_IN],
        [Token::PARAMETER, '「メッセージ」', Token::VAL_STR],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::DISPLAY, Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function debug' do
      mock_reader(
        "それを ポイ捨てる\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, 'それ', Token::VAR_SORE],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::DUMP, Token::FUNC_BUILT_IN],
      )
    end

    # Formatting
    ############################################################################

    it 'tokenizes built-in function format string' do
      mock_reader(
        "「フォーマット文」に それを 書き込む\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '「フォーマット文」', Token::VAL_STR],
        [Token::PARAMETER, 'それ', Token::VAR_SORE],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::FORMAT_STRING, Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function format number' do
      mock_reader(
        "「　詰め4桁。x詰め6桁」で 49を 数値形式にする\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '「　詰め4桁。x詰め6桁」', Token::VAL_STR],
        [Token::PARAMETER, '49', Token::VAL_NUM],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::FORMAT_NUMBER, Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function round' do
      mock_reader(
        "46.49を 「1桁」に 四捨五入する\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '46.49', Token::VAL_NUM],
        [Token::PARAMETER, '「1桁」', Token::VAL_STR],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::ROUND, Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function cast_to_n' do
      mock_reader(
        "「1」を 数値化する\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '「1」', Token::VAL_STR],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::CAST_TO_N, Token::FUNC_BUILT_IN],
      )
    end

    # String / Array Operations
    ############################################################################

    it 'tokenizes built-in function push' do
      %w[押し込む 追加する].each do |name|
        mock_reader(
          "配列に 1を #{name}\n"
        )
        expect(tokens).to contain_exactly(
          [Token::PARAMETER, '配列', Token::VAL_ARRAY],
          [Token::PARAMETER, '1', Token::VAL_NUM],
          [Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, Token::FUNC_BUILT_IN],
        )
      end
    end

    it 'tokenizes built-in function pop' do
      mock_reader(
        "ほげは 1、2、3\n" \
        "ほげから 引き出す\n"
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::RVALUE, '1', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '2', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '3', Token::VAL_NUM],
        [Token::ARRAY_CLOSE],
        [Token::PARAMETER, 'ほげ', Token::VARIABLE],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::POP, Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function unshift' do
      mock_reader(
        "配列に 1を 先頭から押し込む\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '配列', Token::VAL_ARRAY],
        [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::UNSHIFT, Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function shift' do
      mock_reader(
        "ほげは 1、2、3\n" \
        "ほげから 先頭を引き出す\n" \
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::RVALUE, '1', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '2', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '3', Token::VAL_NUM],
        [Token::ARRAY_CLOSE],
        [Token::PARAMETER, 'ほげ', Token::VARIABLE],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::SHIFT, Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function remove' do
      %w[抜く 取る].each do |name|
        mock_reader(
          "ほげは 1、2、2、2\n" \
          "ほげから 2を #{name}\n"
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
          [Token::FUNCTION_CALL, Tokenizer::BuiltIns::REMOVE, Token::FUNC_BUILT_IN],
        )
      end
    end

    it 'tokenizes built-in function remove all' do
      %w[抜く 取る].each do |name|
        mock_reader(
          "ほげは 1、2、2、2\n" \
          "ほげから 2を 全部#{name}\n"
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
          [Token::FUNCTION_CALL, Tokenizer::BuiltIns::REMOVE_ALL, Token::FUNC_BUILT_IN],
        )
      end
    end

    it 'tokenizes built-in function concatenate' do
      mock_reader(
        "配列に 配列を 繋ぐ\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '配列', Token::VAL_ARRAY],
        [Token::PARAMETER, '配列', Token::VAL_ARRAY],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::CONCATENATE, Token::FUNC_BUILT_IN],
      )
    end

    # Math
    ############################################################################

    it 'tokenizes built-in function add' do
      mock_reader(
        "1に 1を 足す\n" \
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function subtract' do
      mock_reader(
        "1から 1を 引く\n" \
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::SUBTRACT, Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function multiply' do
      mock_reader(
        "2に 3を 掛ける\n" \
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '2', Token::VAL_NUM],
        [Token::PARAMETER, '3', Token::VAL_NUM],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::MULTIPLY, Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function divide' do
      mock_reader(
        "10を 2で 割る\n" \
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '10', Token::VAL_NUM],
        [Token::PARAMETER, '2', Token::VAL_NUM],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::DIVIDE, Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes built-in function modulus' do
      mock_reader(
        "7を 3で 割った余りを求める\n" \
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '7', Token::VAL_NUM],
        [Token::PARAMETER, '3', Token::VAL_NUM],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::MODULUS, Token::FUNC_BUILT_IN],
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
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, Token::FUNC_BUILT_IN],
        [Token::PARAMETER, 'それ', Token::VAR_SORE], [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::SUBTRACT, Token::FUNC_BUILT_IN],
        [Token::PARAMETER, 'それ', Token::VAR_SORE], [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::MULTIPLY, Token::FUNC_BUILT_IN],
        [Token::PARAMETER, 'それ', Token::VAR_SORE], [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::DIVIDE, Token::FUNC_BUILT_IN],
        [Token::PARAMETER, 'それ', Token::VAR_SORE], [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::MODULUS, Token::FUNC_BUILT_IN],
      )
    end

    # Misc
    ############################################################################

    it 'tokenizes built-in function raise' do
      mock_reader(
        "「エラー」を 投げる\n"
      )
      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '「エラー」', Token::VAL_STR],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::THROW, Token::FUNC_BUILT_IN],
      )
    end
  end
end
