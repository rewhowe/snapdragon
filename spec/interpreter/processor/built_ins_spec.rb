require './src/token'
require './src/interpreter/processor'
require './src/interpreter/errors'
require './spec/contexts/interpreter'

RSpec.describe Interpreter::Processor, 'assignment' do
  include_context 'interpreter'

  describe '#process' do
    it 'processes built-in print_stdout' do
      mock_lexer(
        Token.new(Token::PARAMETER, '「ほげ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '言う', sub_type: Token::FUNC_BUILT_IN),
      )
      expect { execute } .to output('ほげ').to_stdout
    end

    it 'processes built-in display_stdout' do
      {
        ['1',      Token::VAL_NUM] => '1',
        ['「あ」', Token::VAL_STR] => '"あ"',
        ['正',     Token::VAL_TRUE] => 'true',
        ['偽',     Token::VAL_FALSE] => 'false',
        ['無',     Token::VAL_NULL] => 'null',
        ['配列',   Token::VAL_ARRAY] => '[]',
      } .each do |(token_value, token_sub_type), output_value|
        mock_lexer(
          Token.new(Token::PARAMETER, token_value, particle: 'を', sub_type: token_sub_type),
          Token.new(Token::FUNCTION_CALL, '表示する', sub_type: Token::FUNC_BUILT_IN),
        )
        expect { execute } .to output(output_value + "\n").to_stdout
      end

      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '4', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '3.2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '1.0', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),
        Token.new(Token::PARAMETER, 'それ', particle: 'を', sub_type: Token::VAR_SORE),
        Token.new(Token::FUNCTION_CALL, '表示する', sub_type: Token::FUNC_BUILT_IN),
      )
      expect { execute } .to output("[4, 3.2, 1]\n").to_stdout
    end

    it 'processes built-in dump' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, 'それ', particle: 'を', sub_type: Token::VAR_SORE),
        Token.new(Token::FUNCTION_CALL, 'ポイ捨てる', sub_type: Token::FUNC_BUILT_IN),
      )
      expect { execute } .to output("\e[94m1\e[0m\n").to_stdout

      # dump with stop execution bang
      allow($stdout).to receive(:write) # suppress stdout
      mock_lexer(
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAR_SORE),
        Token.new(Token::FUNCTION_CALL, 'ポイ捨てる', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG),
        Token.new(Token::PARAMETER, '「ほげ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '言う', sub_type: Token::FUNC_BUILT_IN),
      )
      expect { execute } .to raise_error SystemExit
    end

    it 'processes built-in throw' do
      mock_lexer(
        Token.new(Token::PARAMETER, '「ほげ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '投げる', sub_type: Token::FUNC_BUILT_IN),
      )
      allow($stderr).to receive(:write) # suppress stderr
      expect { execute } .to raise_error Interpreter::Errors::CustomError
    end

    it 'processes built-in append' do
      # append to array
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '3', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '4', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '追加する', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq [1, 2, 3]
      expect(sore).to eq [1, 2, 3, 4]

      # append to string
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「ほげ」', sub_type: Token::VAL_STR),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '「ふが」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '追加する', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 'ほげ'
      expect(sore).to eq 'ほげふが'
    end

    it 'processes built-in concat' do
      # concat arrays
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '3', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),

        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '4', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '5', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '6', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'フガ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, '連結する', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq [1, 2, 3]
      expect(variable('フガ')).to eq [4, 5, 6]
      expect(sore).to eq [1, 2, 3, 4, 5, 6]

      # concat strings
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「ほげ」', sub_type: Token::VAL_STR),

        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「ふが」', sub_type: Token::VAL_STR),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'フガ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, '追加する', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 'ほげ'
      expect(variable('フガ')).to eq 'ふが'
      expect(sore).to eq 'ほげふが'
    end

    it 'processes built-in remove' do
      # remove from array
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'から', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '2', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '抜く', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq [1, 2]
      expect(sore).to eq 2

      # remove from string
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「ほげげ」', sub_type: Token::VAL_STR),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'から', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '「げ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '抜く', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 'ほげ'
      expect(sore).to eq 'げ'
    end

    it 'processes built-in remove_all' do
      # remove all from array
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'から', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '2', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '全部抜く', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq [1]
      expect(sore).to eq [2, 2]

      # remove all from string
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「ほげげ」', sub_type: Token::VAL_STR),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'から', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '「げ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '全部抜く', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 'ほ'
      expect(sore).to eq ['げ', 'げ']
    end

    it 'processes built-in push' do
      # push array
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '3', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '押し込む', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq [1, 2, 3]
      expect(sore).to eq [1, 2, 3]

      # push string
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「ほげ」', sub_type: Token::VAL_STR),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '「ふが」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '押し込む', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 'ほげふが'
      expect(sore).to eq 'ほげふが'
    end

    it 'processes built-in pop' do
      # pop array
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '3', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'から', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, '抜き出す', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq [1, 2]
      expect(sore).to eq 3

      # pop string
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「ほげげ」', sub_type: Token::VAL_STR),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'から', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, '抜き出す', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 'ほげ'
      expect(sore).to eq 'げ'
    end

    it 'processes built-in unshift' do
      # unshift array
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '3', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '先頭から押し込む', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq [1, 2, 3]
      expect(sore).to eq [1, 2, 3]

      # unshift string
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「げ」', sub_type: Token::VAL_STR),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '「ほ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '先頭から押し込む', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 'ほげ'
      expect(sore).to eq 'ほげ'
    end

    it 'processes built-in shift' do
      # shift array
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '3', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'から', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, '先頭を抜き出す', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq [2, 3]
      expect(sore).to eq 1

      # shift string
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「ほげ」', sub_type: Token::VAL_STR),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'から', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, '先頭を抜き出す', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 'げ'
      expect(sore).to eq 'ほ'
    end

    it 'processes built-in add' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '7', sub_type: Token::VAL_NUM),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '3', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '足す', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 7
      expect(sore).to eq 10
    end

    it 'processes built-in subtract' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '7', sub_type: Token::VAL_NUM),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'から', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '3', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '引く', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 7
      expect(sore).to eq 4
    end

    it 'processes built-in multiply' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '7', sub_type: Token::VAL_NUM),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '3', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '掛ける', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 7
      expect(sore).to eq 21
    end

    it 'processes built-in divide' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '7', sub_type: Token::VAL_NUM),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '3', particle: 'で', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '割る', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 7
      expect(sore).to eq 7.0/3.0
    end

    it 'processes built-in mod' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '7', sub_type: Token::VAL_NUM),

        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '3', particle: 'で', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, '割った余りを求める', sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 7
      expect(sore).to eq 1
    end
  end
end
