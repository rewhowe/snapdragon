require './src/token'
require './src/interpreter/processor'
require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'misc' do
  include_context 'processor'

  describe '#execute' do
    it 'does not do anything in particular for no-op' do
      mock_lexer(
        Token.new(Token::NO_OP),
      )
      expect { execute } .to_not raise_error
    end

    it 'can process a debug command' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_DEF, 'ほげる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::DEBUG),
        Token.new(Token::PARAMETER, '無', particle: 'を', sub_type: Token::VAL_NULL), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::FUNCTION_CALL, 'ほげる', sub_type: Token::FUNC_USER),
      )
      expect { execute } .to output(
        "\e[94m" \
         "Variables:\n" \
        "・引数列 => {}\n" \
        "・例外 => null\n" \
        "・ホゲ => 1\n" \
        "Functions:\n" \
        "・ほげる\n" \
        "\n" \
        "Variables:\n" \
        "\n" \
        "Functions:\n" \
        "\n" \
        "\n" \
        "それ: 1\n" \
        "あれ: null\e[0m\n"
      ).to_stdout
    end

    it 'stops execution on debug bang' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::DEBUG),
        Token.new(Token::BANG),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
      )
      allow($stdout).to receive(:write) # suppress stdout
      expect { execute } .to raise_error SystemExit
      expect(variable('ホゲ')).to eq 1
    end

    it 'can receive command-line arguments' do
      mock_options argv: ['hoge']
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::POSSESSIVE, '引数列', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '先頭', sub_type: Token::PROP_FIRST),
      )
      execute
      expect(variable('ホゲ')).to eq 'hoge'
    end

    it 'can calculate logarithms' do
      mock_lexer(
        Token.new(Token::PARAMETER, '9', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '729', sub_type: Token::VAL_NUM),
        Token.new(Token::LOGARITHM),
      )
      execute
      expect(sore).to eq 3
    end

    it 'returns "nice" numbers if possible when calculating log' do
      mock_lexer(
        Token.new(Token::PARAMETER, '8', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '134217728', sub_type: Token::VAL_NUM),
        Token.new(Token::LOGARITHM),
      )
      execute
      expect(sore).to eq 9.0
    end

    it 'does not modify original variable when copy is modified' do
      %w[A B].each do |modify_variable|
        # array
        # Aは 配列
        # Bは A
        # modify_variableに 1を 押し込む
        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'A', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
          Token.new(Token::ASSIGNMENT, 'B', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, 'A', sub_type: Token::VARIABLE),
          Token.new(Token::PARAMETER, modify_variable, particle: 'に', sub_type: Token::VARIABLE),
          Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
          Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
        )

        original_array = sd_array []
        modified_array = sd_array [1.0]

        execute
        expect(variable('A')).to eq modify_variable == 'A' ? modified_array : original_array
        expect(variable('B')).to eq modify_variable == 'B' ? modified_array : original_array

        # string
        # Aは 「あいうえお」
        # Bは A
        # modify_variableの 1つ目は 「か」
        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'A', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, 'あいうえお', sub_type: Token::VAL_STR),
          Token.new(Token::ASSIGNMENT, 'B', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, 'A', sub_type: Token::VARIABLE),
          Token.new(Token::POSSESSIVE, modify_variable, sub_type: Token::VARIABLE),
          Token.new(Token::ASSIGNMENT, '1', sub_type: Token::KEY_INDEX),
          Token.new(Token::RVALUE, 'か', sub_type: Token::VAL_STR),
        )

        original_string = 'あいうえお'
        modified_string = 'かいうえお'

        execute
        expect(variable('A')).to eq modify_variable == 'A' ? modified_string : original_string
        expect(variable('B')).to eq modify_variable == 'B' ? modified_string : original_string
      end
    end

    it 'does not modify elements of original variable when elements of copy are modified' do
      {
        'A' => Token::VARIABLE,
        'B' => Token::VARIABLE,
        'あれ' => Token::VAR_ARE,
      }.each do |modify_variable, sub_type|
        # array
        # Aは 配列
        # Aに 配列を 押し込む
        # Bは A
        # あれは A
        # modify_variableの 1つ目に 1を 押し込む
        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'A', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
          Token.new(Token::PARAMETER, 'A', particle: 'に', sub_type: Token::VARIABLE),
          Token.new(Token::PARAMETER, '配列', particle: 'を', sub_type: Token::VAL_ARRAY),
          Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
          Token.new(Token::ASSIGNMENT, 'B', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, 'A', sub_type: Token::VARIABLE),
          Token.new(Token::ASSIGNMENT, 'あれ', sub_type: Token::VAR_ARE),
          Token.new(Token::RVALUE, 'A', sub_type: Token::VARIABLE),
          Token.new(Token::POSSESSIVE, modify_variable, sub_type: sub_type),
          Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::KEY_INDEX),
          Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
          Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
        )

        original_array = sd_array [sd_array([])]
        modified_array = sd_array [sd_array([1.0])]

        execute
        expect(variable('A')).to eq modify_variable == 'A' ? modified_array : original_array
        expect(variable('B')).to eq modify_variable == 'B' ? modified_array : original_array
        expect(are).to eq modify_variable == 'あれ' ? modified_array : original_array

        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'A', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
          Token.new(Token::PARAMETER, 'A', particle: 'に', sub_type: Token::VARIABLE),
          Token.new(Token::PARAMETER, 'あいうえお', particle: 'を', sub_type: Token::VAL_STR),
          Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
          Token.new(Token::ASSIGNMENT, 'B', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, 'A', sub_type: Token::VARIABLE),
          Token.new(Token::ASSIGNMENT, 'あれ', sub_type: Token::VAR_ARE),
          Token.new(Token::RVALUE, 'A', sub_type: Token::VARIABLE),
          Token.new(Token::POSSESSIVE, modify_variable, sub_type: sub_type),
          Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::KEY_INDEX),
          Token.new(Token::PARAMETER, 'か', particle: 'を', sub_type: Token::VAL_STR),
          Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
        )

        original_string = sd_array ['あいうえお']
        modified_string = sd_array ['あいうえおか']

        execute
        expect(variable('A')).to eq modify_variable == 'A' ? modified_string : original_string
        expect(variable('B')).to eq modify_variable == 'B' ? modified_string : original_string
        expect(are).to eq modify_variable == 'あれ' ? modified_string : original_string
      end
    end

    it 'does not modify element inserted into array, even if original variable inserted as element is changed' do
      # Aは 配列
      # Bは 配列
      # Cは 1,B
      # Cに Aを 押し込む
      # Aに 2を 押し込む
      # Bに 3を 押し込む
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'A', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::ASSIGNMENT, 'B', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::ASSIGNMENT, 'C', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, 'B', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_CLOSE),
        Token.new(Token::PARAMETER, 'C', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'A', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::PARAMETER, 'A', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '2', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::PARAMETER, 'B', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '3', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
      )

      execute
      expect(variable('A')).to eq sd_array [2.0]
      expect(variable('B')).to eq sd_array [3.0]
      expect(variable('C')).to eq sd_array [1.0, sd_array([]), sd_array([])]
    end

    it 'does not modify original variable when function parameter is modified' do
      # array
      # Aは 配列,配列
      # aを ほげるとは
      #   aの 1つ目に 1を押し込む
      #   aに 1を 押し込む
      #   aを 返す
      # Aを ほげる
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'A', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::ARRAY_CLOSE),
        Token.new(Token::PARAMETER, 'a', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_DEF, 'ほげる', sub_type: Token::FUNC_USER),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::POSSESSIVE, 'a', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::KEY_INDEX),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::PARAMETER, 'a', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::PARAMETER, 'a', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::PARAMETER, 'A', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, 'ほげる', sub_type: Token::FUNC_USER),
      )

      execute
      expect(variable('A')).to eq sd_array [sd_array([]), sd_array([])]
      expect(sore).to eq sd_array [sd_array([1.0]), sd_array([]), 1.0]

      # string
      # Aは 「あいうえお」
      # aを ほげるとは
      #   aの 1つ目は 「か」
      #   aに 「き」を 押し込む
      #   aを 返す
      # Aを ほげる
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'A', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'あいうえお', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'a', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_DEF, 'ほげる', sub_type: Token::FUNC_USER),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::POSSESSIVE, 'a', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '1', sub_type: Token::KEY_INDEX),
        Token.new(Token::RVALUE, 'か', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'a', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'き', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::PARAMETER, 'a', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::PARAMETER, 'A', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, 'ほげる', sub_type: Token::FUNC_USER),
      )

      execute
      expect(variable('A')).to eq 'あいうえお'
      expect(sore).to eq 'かいうえおき'
    end

    it 'does not modify function parameter when original variable is modified' do
      # array
      # Aは 配列,配列
      # aを ほげるとは
      #   aを 返す
      # Aを ほげる
      # Bは それ
      # Aの 1つ目に 1を押し込む
      # Aに 1を 押し込む
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'A', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::ARRAY_CLOSE),
        Token.new(Token::PARAMETER, 'a', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_DEF, 'ほげる', sub_type: Token::FUNC_USER),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'a', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::PARAMETER, 'A', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, 'ほげる', sub_type: Token::FUNC_USER),
        Token.new(Token::ASSIGNMENT, 'B', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::POSSESSIVE, 'A', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::KEY_INDEX),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::PARAMETER, 'A', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
      )

      execute
      expect(variable('A')).to eq sd_array [sd_array([1.0]), sd_array([]), 1.0]
      expect(variable('B')).to eq sd_array [sd_array([]), sd_array([])]

      # string
      # Aは 「あいうえお」
      # aを ほげるとは
      #   aを 返す
      # Aを ほげる
      # Bは それ
      # Aの 1つ目は 「か」
      # Aに 「き」を 押し込む
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'A', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'あいうえお', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'a', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_DEF, 'ほげる', sub_type: Token::FUNC_USER),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'a', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::PARAMETER, 'A', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, 'ほげる', sub_type: Token::FUNC_USER),
        Token.new(Token::ASSIGNMENT, 'B', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::POSSESSIVE, 'A', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '1', sub_type: Token::KEY_INDEX),
        Token.new(Token::RVALUE, 'か', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'A', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'き', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
      )

      execute
      expect(variable('A')).to eq 'かいうえおき'
      expect(variable('B')).to eq 'あいうえお'
    end

    it 'does not modify original variable when modifying sore' do
      # array
      # Aは 配列
      # それに 1を 押し込む
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'A', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::PARAMETER, 'それ', particle: 'に', sub_type: Token::VAR_SORE),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
      )

      execute
      expect(variable('A')).to eq sd_array []
      expect(sore).to eq sd_array [1.0]

      # string
      # Aは 「あいうえお」
      # それの 1つ目は 「か」
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'A', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'あいうえお', sub_type: Token::VAL_STR),
        Token.new(Token::POSSESSIVE, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::ASSIGNMENT, '1', sub_type: Token::KEY_INDEX),
        Token.new(Token::RVALUE, 'か', sub_type: Token::VAL_STR),
      )

      execute
      expect(variable('A')).to eq 'あいうえお'
      expect(sore).to eq 'か'
    end
  end
end
