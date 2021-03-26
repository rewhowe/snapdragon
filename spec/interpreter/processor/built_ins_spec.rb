require './src/token'
require './src/tokenizer/built_ins'
require './src/interpreter/processor'
require './src/interpreter/errors'
require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'built-ins' do
  include_context 'processor'

  describe '#execute' do
    # Output
    ############################################################################
    it 'processes built-in print_stdout' do
      mock_lexer(
        Token.new(Token::PARAMETER, '「ほげ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PRINT, sub_type: Token::FUNC_BUILT_IN),
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
        ['配列',   Token::VAL_ARRAY] => '{}',
      } .each do |(token_value, token_sub_type), output_value|
        mock_lexer(
          Token.new(Token::PARAMETER, token_value, particle: 'を', sub_type: token_sub_type),
          Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::DISPLAY, sub_type: Token::FUNC_BUILT_IN),
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
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::DISPLAY, sub_type: Token::FUNC_BUILT_IN),
      )
      expect { execute } .to output("{0: 4, 1: 3.2, 2: 1}\n").to_stdout
    end

    it 'processes built-in dump' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, 'それ', particle: 'を', sub_type: Token::VAR_SORE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::DUMP, sub_type: Token::FUNC_BUILT_IN),
      )
      expect { execute } .to output("\e[94m1\e[0m\n").to_stdout

      # dump with stop execution bang
      allow($stdout).to receive(:write) # suppress stdout
      mock_lexer(
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAR_SORE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::DUMP, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::BANG),
        Token.new(Token::PARAMETER, '「ほげ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PRINT, sub_type: Token::FUNC_BUILT_IN),
      )
      expect { execute } .to raise_error SystemExit
    end

    # Formatting
    ############################################################################

    it 'processes built-in format_string' do
      # format array of parameters
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '3', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),
        # backslashes need to be doubly-doubled
        Token.new(Token::PARAMETER, '「あ〇い〇う\\〇え\\\\\\\\〇お」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FORMAT_STRING, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq 'あ1い2う〇え\\3お'

      # format single value
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '「あ〇い\\〇う」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FORMAT_STRING, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq 'あ1い〇う'
    end

    it 'processes built-in format_number' do
      # format with various values
      mock_lexer(
        Token.new(Token::PARAMETER, '「　詰め4桁。x詰め6桁」', particle: 'で', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '4.9', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FORMAT_NUMBER, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq '　　　4.9xxxxx'

      # format with defaults
      mock_lexer(
        Token.new(Token::PARAMETER, '「2桁」', particle: 'で', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '4649', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FORMAT_NUMBER, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq '49'
    end

    it 'processes built-in round' do
      {
        '1' => 46.5,
        '0' => 46,
        '-1' => 50,
      }.each do |digits, result|
        mock_lexer(
          Token.new(Token::PARAMETER, '46.49', particle: 'を', sub_type: Token::VAL_NUM),
          Token.new(Token::PARAMETER, "「#{digits}桁」", particle: 'に', sub_type: Token::VAL_STR),
          Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ROUND, sub_type: Token::FUNC_BUILT_IN),
        )
        execute
        expect(sore).to eq result
      end
    end

    it 'processes built-in cast_to_n' do
      {
        '5' => { sub_type: Token::VAL_NUM, result: 5 },
        '4.6' => { sub_type: Token::VAL_NUM, result: 4.6 },
        '「4.9」' => { sub_type: Token::VAL_STR, result: 4.9 },
        '配列' => { sub_type: Token::VAL_ARRAY, result: 0 },
        '真' => { sub_type: Token::VAL_TRUE, result: 1 },
        '偽' => { sub_type: Token::VAL_FALSE, result: 0 },
        '無' => { sub_type: Token::VAL_ARRAY, result: 0 },
      }.each do |parameter, test|
        mock_lexer(
          Token.new(Token::PARAMETER, parameter, particle: 'を', sub_type: test[:sub_type]),
          Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::CAST_TO_N, sub_type: Token::FUNC_BUILT_IN),
        )
        execute
        expect(sore).to eq test[:result]
      end
    end

    it 'processes built-in cast_to_i' do
      {
        '5' => { sub_type: Token::VAL_NUM, result: 5 },
        '4.6' => { sub_type: Token::VAL_NUM, result: 4 },
        '「4.9」' => { sub_type: Token::VAL_STR, result: 4 },
        '配列' => { sub_type: Token::VAL_ARRAY, result: 0 },
        '真' => { sub_type: Token::VAL_TRUE, result: 1 },
        '偽' => { sub_type: Token::VAL_FALSE, result: 0 },
        '無' => { sub_type: Token::VAL_ARRAY, result: 0 },
      }.each do |parameter, test|
        mock_lexer(
          Token.new(Token::PARAMETER, parameter, particle: 'を', sub_type: test[:sub_type]),
          Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::CAST_TO_I, sub_type: Token::FUNC_BUILT_IN),
        )
        execute
        expect(sore).to eq test[:result]
      end
    end

    # String / Array Operations
    ############################################################################

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
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq sd_array [1, 2, 3]
      expect(sore).to eq sd_array [1, 2, 3]

      # push string
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「ほげ」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '「ふが」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
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
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::POP, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq sd_array [1, 2]
      expect(sore).to eq 3

      # pop string
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「ほげげ」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'から', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::POP, sub_type: Token::FUNC_BUILT_IN),
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
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::UNSHIFT, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq sd_array [1, 2, 3]
      expect(sore).to eq sd_array [1, 2, 3]

      # unshift string
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「げ」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '「ほ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::UNSHIFT, sub_type: Token::FUNC_BUILT_IN),
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
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::SHIFT, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq sd_array [2, 3]
      expect(sore).to eq 1

      # shift string
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「ほげ」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'から', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::SHIFT, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 'げ'
      expect(sore).to eq 'ほ'
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
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::REMOVE, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq sd_array('0' => 1, '2' => 2)
      expect(sore).to eq 2

      # remove from string
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「ほげげ」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'から', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '「げ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::REMOVE, sub_type: Token::FUNC_BUILT_IN),
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
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::REMOVE_ALL, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq sd_array('0' => 1)
      expect(sore).to eq sd_array('0' => 2, '1' => 2)

      # remove all from string
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「ほげげ」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'から', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '「げ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::REMOVE_ALL, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 'ほ'
      expect(sore).to eq %w[げ げ]
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
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::CONCATENATE, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq sd_array [1, 2, 3]
      expect(variable('フガ')).to eq sd_array [4, 5, 6]
      expect(sore).to eq sd_array [1, 2, 3, 4, 5, 6]

      # concat strings
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「ほげ」', sub_type: Token::VAL_STR),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「ふが」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'フガ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::CONCATENATE, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 'ほげ'
      expect(variable('フガ')).to eq 'ふが'
      expect(sore).to eq 'ほげふが'
    end

    it 'processes built-in join' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '「あ」', sub_type: Token::VAL_STR), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
        Token.new(Token::ARRAY_CLOSE),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '「、」', particle: 'で', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::JOIN, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq '1、あ、はい'
    end

    # Math
    ############################################################################

    it 'processes built-in add' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '7', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '3', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, sub_type: Token::FUNC_BUILT_IN),
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
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::SUBTRACT, sub_type: Token::FUNC_BUILT_IN),
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
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::MULTIPLY, sub_type: Token::FUNC_BUILT_IN),
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
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::DIVIDE, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 7
      expect(sore).to eq 7.0 / 3.0
    end

    it 'processes built-in mod' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '7', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '3', particle: 'で', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::MODULUS, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 7
      expect(sore).to eq 1
    end

    # Misc
    ############################################################################

    it 'processes built-in throw' do
      mock_lexer(
        Token.new(Token::PARAMETER, '「ほげ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::THROW, sub_type: Token::FUNC_BUILT_IN),
      )
      allow($stderr).to receive(:write) # suppress stderr
      expect { execute } .to raise_error Interpreter::Errors::CustomError
    end

    # Boolean Casting
    ############################################################################
    # Only covers v1.0.0 built-ins.
    ############################################################################
    [
      { tokens: [
        Token.new(Token::PARAMETER, '「ほげ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PRINT, sub_type: Token::FUNC_BUILT_IN),
      ], result: true },
      { tokens: [
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::DISPLAY, sub_type: Token::FUNC_BUILT_IN),
      ], result: true },
      { tokens: [
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::DUMP, sub_type: Token::FUNC_BUILT_IN),
      ], result: true },
      # NOTE: no test for 投げる because it throws an error anyway
      { tokens: [
        Token.new(Token::PARAMETER, '配列', particle: 'に', sub_type: Token::VAL_ARRAY),
        Token.new(Token::PARAMETER, '配列', particle: 'を', sub_type: Token::VAL_ARRAY),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::CONCATENATE, sub_type: Token::FUNC_BUILT_IN),
      ], result: false },
      { tokens: [
        Token.new(Token::PARAMETER, '「あ」', particle: 'から', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'あ', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::REMOVE, sub_type: Token::FUNC_BUILT_IN),
      ], result: true },
      { tokens: [
        Token.new(Token::PARAMETER, '「ああ」', particle: 'から', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '「あ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::REMOVE_ALL, sub_type: Token::FUNC_BUILT_IN),
      ], result: true },
      { tokens: [
        Token.new(Token::PARAMETER, '配列', particle: 'に', sub_type: Token::VAL_ARRAY),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
      ], result: true },
      { tokens: [
        Token.new(Token::PARAMETER, '「あ」', particle: 'から', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::POP, sub_type: Token::FUNC_BUILT_IN),
      ], result: true },
      { tokens: [
        Token.new(Token::PARAMETER, '「」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '「あ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::UNSHIFT, sub_type: Token::FUNC_BUILT_IN),
      ], result: true },
      { tokens: [
        Token.new(Token::PARAMETER, '「あ」', particle: 'から', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::SHIFT, sub_type: Token::FUNC_BUILT_IN),
      ], result: true },
      { tokens: [
        Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, sub_type: Token::FUNC_BUILT_IN),
      ], result: true },
      { tokens: [
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::SUBTRACT, sub_type: Token::FUNC_BUILT_IN),
      ], result: false },
      { tokens: [
        Token.new(Token::PARAMETER, '999', particle: 'に', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '0', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::MULTIPLY, sub_type: Token::FUNC_BUILT_IN),
      ], result: false },
      { tokens: [
        Token.new(Token::PARAMETER, '10', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '2', particle: 'で', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::DIVIDE, sub_type: Token::FUNC_BUILT_IN),
      ], result: true },
      { tokens: [
        Token.new(Token::PARAMETER, '7', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '3', particle: 'で', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::MODULUS, sub_type: Token::FUNC_BUILT_IN),
      ], result: true },
    ].each do |test|
      built_in = test[:tokens].last.content
      it "processes built-in #{built_in} with boolean cast" do
        mock_lexer(*test[:tokens], Token.new(Token::QUESTION))
        allow($stdout).to receive(:write) # suppress stdout
        execute
        expect(sore).to eq test[:result]
      end
    end
  end
end
