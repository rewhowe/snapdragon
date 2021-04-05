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

    it 'processes built-in format' do
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
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FORMAT, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq 'あ1い2う〇え\\3お'

      # format single value
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '「あ〇い\\〇う」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FORMAT, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq 'あ1い〇う'

      # format number with various values
      mock_lexer(
        Token.new(Token::PARAMETER, '「〇(　詰め4桁。x詰め6桁)」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '4.9', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FORMAT, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq '　　　4.9xxxxx'

      # format with defaults
      mock_lexer(
        Token.new(Token::PARAMETER, '「〇（2桁）」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '4649', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FORMAT, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq '4649'

      # do not format if escaped
      mock_lexer(
        Token.new(Token::PARAMETER, '「〇\\（8桁）」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '4649', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FORMAT, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq '4649（8桁）'

      # do not format if escaped (quadrupley escaped leaves backslashes)
      mock_lexer(
        Token.new(Token::PARAMETER, '「〇\\\\\\\\（8桁）」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '4649', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FORMAT, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq '4649\\（8桁）'
    end

    it 'processes built-in round_up' do
      {
        '0桁' => 4649.4649,
        '1桁' => 4650,
        '2桁' => 4650,
        '3桁' => 4700,
        '4桁' => 5000,
        '5桁' => 10_000,
        '小数第0位' => 4649.4649,
        '小数第1位' => 4649.5,
        '小数第2位' => 4649.47,
        '小数第3位' => 4649.465,
        '小数第4位' => 4649.4649,
        '小数第5位' => 4649.4649,
      }.each do |precision, result|
        mock_lexer(
          Token.new(Token::PARAMETER, '4649.4649', particle: 'を', sub_type: Token::VAL_NUM),
          Token.new(Token::PARAMETER, "「#{precision}」", particle: 'に', sub_type: Token::VAL_STR),
          Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ROUND_UP, sub_type: Token::FUNC_BUILT_IN),
        )
        execute
        expect(sore).to eq result
      end
    end

    it 'processes built-in round_down' do
      {
        '0桁' => 4649.4649,
        '1桁' => 4649,
        '2桁' => 4640,
        '3桁' => 4600,
        '4桁' => 4000,
        '5桁' => 0,
        '小数第0位' => 4649.4649,
        '小数第1位' => 4649.4,
        '小数第2位' => 4649.46,
        '小数第3位' => 4649.464,
        '小数第4位' => 4649.4649,
        '小数第5位' => 4649.4649,
      }.each do |precision, result|
        mock_lexer(
          Token.new(Token::PARAMETER, '4649.4649', particle: 'を', sub_type: Token::VAL_NUM),
          Token.new(Token::PARAMETER, "「#{precision}」", particle: 'に', sub_type: Token::VAL_STR),
          Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ROUND_DOWN, sub_type: Token::FUNC_BUILT_IN),
        )
        execute
        expect(sore).to eq result
      end
    end

    it 'processes built-in round_nearest' do
      {
        '0桁' => 4649.4649,
        '1桁' => 4649,
        '2桁' => 4650,
        '3桁' => 4600,
        '4桁' => 5000,
        '5桁' => 0,
        '小数点第0位' => 4649.4649,
        '小数点第1位' => 4649.5,
        '小数点第2位' => 4649.46,
        '小数点第3位' => 4649.465,
        '小数点第4位' => 4649.4649,
        '小数点第5位' => 4649.4649,
      }.each do |precision, result|
        mock_lexer(
          Token.new(Token::PARAMETER, '4649.4649', particle: 'を', sub_type: Token::VAL_NUM),
          Token.new(Token::PARAMETER, "「#{precision}」", particle: 'に', sub_type: Token::VAL_STR),
          Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ROUND_NEAREST, sub_type: Token::FUNC_BUILT_IN),
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

    it 'processes built-in split' do
      # split arrays
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '「あ」', sub_type: Token::VAL_STR), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '偽', sub_type: Token::VAL_FALSE), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '無', sub_type: Token::VAL_NULL), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '正', sub_type: Token::VAL_TRUE),
        Token.new(Token::ARRAY_CLOSE),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'はい', particle: 'で', sub_type: Token::VAL_TRUE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::SPLIT, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq sd_array [sd_array([1, 'あ']), sd_array([false, nil]), sd_array]

      # split strings
      mock_lexer(
        Token.new(Token::PARAMETER, '「little red hat」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, '「 」', particle: 'で', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::SPLIT, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq sd_array %w[little red hat]
    end

    it 'processes built-in slice' do
      # slice arrays
      mock_lexer(
        # make array {0: 1, 1: 2, 2: 3, え: 4, 4: 5, 5: 6}
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '3', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '「え」', sub_type: Token::KEY_NAME),
        Token.new(Token::RVALUE, '4', sub_type: Token::VAL_NUM),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '5', sub_type: Token::KEY_INDEX),
        Token.new(Token::RVALUE, '5', sub_type: Token::VAL_NUM),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '「5」', sub_type: Token::KEY_NAME),
        Token.new(Token::RVALUE, '6', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '2', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '4', particle: 'まで', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::SLICE, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq sd_array('0' => 1, '1' => 2, '5' => 6)
      expect(sore).to eq sd_array('0' => 3, 'え' => 4, '1' => 5)

      # slice strings
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「あいうえおかきくけこ」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '2', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '4', particle: 'まで', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::SLICE, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq 'あいかきくけこ'
      expect(sore).to eq 'うえお'

      # boundaries clamp
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '-1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '100', particle: 'まで', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::SLICE, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(variable('ホゲ')).to eq ''
      expect(sore).to eq 'あいうえお'
    end

    it 'processes built-in find' do
      # find in array (string key)
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '「キー名」', sub_type: Token::KEY_NAME),
        Token.new(Token::RVALUE, '「ふが」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'で', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '「ふが」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FIND, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq 'キー名'

      # find in array (numeric key)
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '3', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'で', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '2', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FIND, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq 1

      # find in string
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'で', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '「う」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FIND, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq 2

      # return null on not found
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'で', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '「か」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::FIND, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to be_nil
    end

    it 'processes built-in sort' do
      # creates an array {0: 2, 1: 1, 2: 3, 6: true, 4: "い", "ほげ": "う", 4.6: "あ"}
      array_tokens = [
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '3', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '7', sub_type: Token::KEY_INDEX),
        Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '5', sub_type: Token::KEY_INDEX),
        Token.new(Token::RVALUE, '「い」', sub_type: Token::VAL_STR),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '「ほげ」', sub_type: Token::KEY_NAME),
        Token.new(Token::RVALUE, '「う」', sub_type: Token::VAL_STR),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '「4.6」', sub_type: Token::KEY_NAME),
        Token.new(Token::RVALUE, '「あ」', sub_type: Token::VAL_STR),
      ]

      # ascending order
      mock_lexer(
        *array_tokens,
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '「昇順」', particle: 'で', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::SORT, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      result = sore.to_a
      {
        '1.0' => 1.0,
        '0.0' => 2.0,
        '2.0' => 3.0,
        '4.6' => 'あ',
        '4.0' => 'い',
        'ほげ' => 'う',
        '6.0' => true,
      }.each do |expected_key, expected_value|
        actual = result.shift
        expect(actual[0]).to eq expected_key
        expect(actual[1]).to eq expected_value
      end

      # descending order
      mock_lexer(
        *array_tokens,
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '「降順」', particle: 'で', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::SORT, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      result = sore.to_a
      {
        '6.0' => true,
        'ほげ' => 'う',
        '4.0' => 'い',
        '4.6' => 'あ',
        '2.0' => 3.0,
        '0.0' => 2.0,
        '1.0' => 1.0,
      }.each do |expected_key, expected_value|
        actual = result.shift
        expect(actual[0]).to eq expected_key
        expect(actual[1]).to eq expected_value
      end
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

    it 'processes built-in srand and rand' do
      mock_lexer(
        Token.new(Token::PARAMETER, '4649', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::SRAND, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::PARAMETER, '0', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '100000', particle: 'まで', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::RAND, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq 90_379
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
