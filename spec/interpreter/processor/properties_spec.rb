require './src/token'
require './src/tokenizer/built_ins'
require './src/interpreter/processor'
require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'properties' do
  include_context 'processor'

  describe '#execute' do
    it 'can assign string length to another variable' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '長さ', sub_type: Token::PROP_LEN),
      )
      execute
      expect(variable('フガ')).to eq 5
    end

    it 'can assign array length to another variable' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '3', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '長さ', sub_type: Token::PROP_LEN),
      )
      execute
      expect(variable('フガ')).to eq 3
    end

    it 'can assign a boolean-casted property to another variable' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '長さ', sub_type: Token::PROP_LEN),
        Token.new(Token::QUESTION),
      )
      execute
      expect(variable('フガ')).to eq true
    end

    it 'can perform assignment with key index' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '1', sub_type: Token::KEY_INDEX),
        Token.new(Token::RVALUE, '4649', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '1', sub_type: Token::KEY_INDEX),
      )
      execute
      expect(variable('フガ')).to eq 4649
    end

    it 'can perform assignment with key name' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '「キー名」', sub_type: Token::KEY_NAME),
        Token.new(Token::RVALUE, '4649', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '「キー名」', sub_type: Token::KEY_NAME),
      )
      execute
      expect(variable('フガ')).to eq 4649
    end

    it 'can perform assignment with key name including string interpolation' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'キー名', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'あ', sub_type: Token::VAL_STR),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '「【キー名】」', sub_type: Token::KEY_NAME),
        Token.new(Token::RVALUE, '4649', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '「【キー名】」', sub_type: Token::KEY_NAME),
      )
      execute
      expect(variable('フガ')).to eq 4649
    end

    it 'can perform assignment with key variable' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'キー名', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'あ', sub_type: Token::VAL_STR),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, 'キー名', sub_type: Token::KEY_VAR),
        Token.new(Token::RVALUE, '4649', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, 'キー名', sub_type: Token::KEY_VAR),
      )
      execute
      expect(variable('フガ')).to eq 4649
    end

    it 'can perform assignment with key sore' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '「キー名」', sub_type: Token::KEY_NAME),
        Token.new(Token::RVALUE, '4649', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::RVALUE, '「キー名」', sub_type: Token::VAL_STR),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, 'それ', sub_type: Token::KEY_SORE),
      )
      execute
      expect(variable('フガ')).to eq 4649
    end

    it 'can perform assignment with key are' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'あれ', sub_type: Token::VAR_ARE),
        Token.new(Token::RVALUE, '「キー名」', sub_type: Token::VAL_STR),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '「キー名」', sub_type: Token::KEY_NAME),
        Token.new(Token::RVALUE, '4649', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, 'あれ', sub_type: Token::KEY_ARE),
      )
      execute
      expect(variable('フガ')).to eq 4649
    end

    it 'can assign an array of boolean-casted properties' do
      mock_lexer(
        *hoge_fuga_array_tokens,
        Token.new(Token::ASSIGNMENT, 'ピヨ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '長さ', sub_type: Token::PROP_LEN),
        Token.new(Token::QUESTION),
        Token.new(Token::COMMA),
        Token.new(Token::POSSESSIVE, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '長さ', sub_type: Token::PROP_LEN),
        Token.new(Token::QUESTION),
        Token.new(Token::ARRAY_CLOSE),
      )
      execute
      expect(variable('ピヨ')).to eq sd_array [true, true]
    end

    it 'can call a user function with property parameters' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'フガ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_DEF, 'ほげる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'フガ', particle: 'を', sub_type: Token::VARIABLE), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '長さ', particle: 'を', sub_type: Token::PROP_LEN),
        Token.new(Token::FUNCTION_CALL, 'ほげる', sub_type: Token::FUNC_USER),
      )
      execute
      expect(sore).to eq 5
    end

    it 'can return a property from a function' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'フガ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_DEF, 'ほげる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::POSSESSIVE, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '長さ', particle: 'を', sub_type: Token::PROP_LEN), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, 'ほげる', sub_type: Token::FUNC_USER),
      )
      execute
      expect(sore).to eq 5
    end

    it 'can call a built-in function with property parameters' do
      mock_lexer(
        *hoge_fuga_array_tokens,
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '長さ', particle: 'に', sub_type: Token::PROP_LEN),
        Token.new(Token::POSSESSIVE, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '長さ', particle: 'を', sub_type: Token::PROP_LEN),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq 8
    end

    it 'can execute a loop with property parameters' do
      mock_lexer(
        *hoge_fuga_array_tokens,
        Token.new(Token::ASSIGNMENT, 'ピヨ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM),
        Token.new(Token::POSSESSIVE, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '長さ', particle: 'から', sub_type: Token::PROP_LEN),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '長さ', particle: 'まで', sub_type: Token::PROP_LEN),
        Token.new(Token::LOOP),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'ピヨ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::ASSIGNMENT, 'ピヨ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(variable('ピヨ')).to eq 3
    end

    it 'can test an if condition with property parameters' do
      mock_lexer(
        *hoge_fuga_array_tokens,
        Token.new(Token::IF),
        Token.new(Token::COMP_GT),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '長さ', sub_type: Token::PROP_LEN),
        Token.new(Token::POSSESSIVE, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '長さ', sub_type: Token::PROP_LEN),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::RVALUE, '10', sub_type: Token::VAL_NUM),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(sore).to eq 10
    end

    it 'can interpolate a string with property length' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「あいう」', sub_type: Token::VAL_STR),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「12【ホゲの 文字数】45」', sub_type: Token::VAL_STR),
      )
      execute
      expect(variable('フガ')).to eq '12345'
    end

    it 'can interpolate a string with property length surrounded by lots of whitespace' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「あいう」', sub_type: Token::VAL_STR),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「1 2 【 　 ホゲの 　 文字数 　 】 4 5」', sub_type: Token::VAL_STR),
      )
      execute
      expect(variable('フガ')).to eq '1 2 3 4 5'
    end

    it 'can interpolate a string with properties key index and key name' do
      [
        '3文字目',
        '「2」',
      ].each do |property|
        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
          Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, "「1 2 【ホゲの #{property}】 4 5」", sub_type: Token::VAL_STR),
        )
        execute
        expect(variable('フガ')).to eq '1 2 う 4 5'
      end
    end

    it 'can interpolate a string with property key variable, key sore, and key are' do
      {
        'キー名' => Token::VARIABLE,
        'それ'   => Token::VAR_SORE,
        'あれ'   => Token::VAR_ARE,
      }.each do |property, sub_type|
        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
          Token.new(Token::ASSIGNMENT, property, sub_type: sub_type),
          Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
          Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, "「1 2 【ホゲの #{property}】 4 5」", sub_type: Token::VAL_STR),
        )
        execute
        expect(variable('フガ')).to eq '1 2 う 4 5'
      end
    end

    it 'treats all array keys as floated strings' do
      {
        '整数指数' => {
          sub_type: Token::KEY_VAR,
          extra_tokens: [
            Token.new(Token::ASSIGNMENT, '整数指数', sub_type: Token::VARIABLE),
            Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
          ],
        },
        '浮動小数点指数' => {
          sub_type: Token::KEY_VAR,
          extra_tokens: [
            Token.new(Token::ASSIGNMENT, '浮動小数点指数', sub_type: Token::VARIABLE),
            Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
          ],
        },
        '「2」' => {
          sub_type: Token::KEY_NAME,
          extra_tokens: [],
        },
        '「2.0」' => {
          sub_type: Token::KEY_NAME,
          extra_tokens: [],
        }
      }.each do |property, test|
        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
          *test[:extra_tokens],
          Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
          Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
          Token.new(Token::PROPERTY, property, sub_type: test[:sub_type]),
        )
        execute
        expect(variable('フガ')).to eq 'う'
      end
    end

    it 'treats null keys as empty strings' do
      {
        '「」' => Token::KEY_NAME,
        'キー名' => Token::KEY_VAR,
      }.each do |property, sub_type|
        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
          Token.new(Token::ASSIGNMENT, 'キー名', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, '無', sub_type: Token::VAL_NULL),
          Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
          Token.new(Token::ASSIGNMENT, property, sub_type: sub_type),
          Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        )
        execute
        expect(variable('ホゲ')).to eq sd_array('' => 1)
      end
    end

    it 'formats boolean keys into strings' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::ASSIGNMENT, 'キー名', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, 'キー名', sub_type: Token::KEY_VAR),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'キー名', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '偽', sub_type: Token::VAL_FALSE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, 'キー名', sub_type: Token::KEY_VAR),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
      )
      execute
      expect(variable('ホゲ')).to eq sd_array('はい' => 1, 'いいえ' => 2)
    end

    it 'returns null on missing array indices' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '「存在しないキー名」', sub_type: Token::KEY_NAME),
      )
      execute
      expect(variable('フガ')).to eq nil
    end

    it 'returns null on invalid string indices' do
      {
        '2.0' => { sub_type: Token::KEY_INDEX, result: 'い' },
        '2.1' => { sub_type: Token::KEY_INDEX, result: nil },
        '「ぴよ」' => { sub_type: Token::KEY_NAME, result: nil },
        'キー名' => {
          sub_type: Token::KEY_VAR,
          extra_tokens: [
            Token.new(Token::ASSIGNMENT, 'キー名', sub_type: Token::VARIABLE),
            Token.new(Token::RVALUE, '「ぴよ」', sub_type: Token::VAL_STR),
          ],
          result: nil
        },
        'それ' => {
          sub_type: Token::KEY_SORE,
          extra_tokens: [
            Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
            Token.new(Token::RVALUE, '「ぴよ」', sub_type: Token::VAL_STR),
          ],
          result: nil
        },
        'あれ' => {
          sub_type: Token::KEY_ARE,
          extra_tokens: [
            Token.new(Token::ASSIGNMENT, 'あれ', sub_type: Token::VAR_ARE),
            Token.new(Token::RVALUE, '「ぴよ」', sub_type: Token::VAL_STR),
          ],
          result: nil
        },
      }.each do |property, test|
        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
          *test[:extra_tokens],
          Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
          Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
          Token.new(Token::PROPERTY, property, sub_type: test[:sub_type]),
        )
        execute
        expect(variable('フガ')).to eq test[:result]
      end
    end

    it 'processes properties in pure function calls' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::KEY_INDEX),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '2', particle: 'を', sub_type: Token::KEY_INDEX),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq 3
    end

    it 'processes properties in mutating function calls' do
      [
        {
          function_call_tokens: [
            Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
            Token.new(Token::PARAMETER, '「え」', particle: 'を', sub_type: Token::VAL_STR),
            Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
          ],
          result: { 0 => 'あ', 'ほげ' => 'い', '4.6' => 'う', 5 => 'え' },
        },
        {
          function_call_tokens: [
            Token.new(Token::PARAMETER, 'ホゲ', particle: 'から', sub_type: Token::VARIABLE),
            Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::POP, sub_type: Token::FUNC_BUILT_IN),
          ],
          result: { 0 => 'あ', 'ほげ' => 'い' },
        },
        {
          function_call_tokens: [
            Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
            Token.new(Token::PARAMETER, '「え」', particle: 'を', sub_type: Token::VAL_STR),
            Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::UNSHIFT, sub_type: Token::FUNC_BUILT_IN),
          ],
          result: { 0 => 'え', 1 => 'あ', 'ほげ' => 'い', 2 => 'う' },
        },
        {
          function_call_tokens: [
            Token.new(Token::PARAMETER, 'ホゲ', particle: 'から', sub_type: Token::VARIABLE),
            Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::SHIFT, sub_type: Token::FUNC_BUILT_IN),
          ],
          result: { 'ほげ' => 'い', 0 => 'う' },
        },
      ].each do |test|
        mock_lexer(
          *hoge_mixed_array_tokens,
          *test[:function_call_tokens],
        )
        execute
        expect(variable('ホゲ')).to eq sd_array test[:result]
      end
    end

    it 'processes properties in concatenation' do
      mock_lexer(
        *hoge_mixed_array_tokens,
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::POSSESSIVE, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '1', sub_type: Token::KEY_INDEX),
        Token.new(Token::RVALUE, '「か」', sub_type: Token::VAL_STR),
        Token.new(Token::POSSESSIVE, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '「ほげ」', sub_type: Token::KEY_NAME),
        Token.new(Token::RVALUE, '「き」', sub_type: Token::VAL_STR),
        Token.new(Token::POSSESSIVE, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '「ふが」', sub_type: Token::KEY_NAME),
        Token.new(Token::RVALUE, '「く」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'フガ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::CONCATENATE, sub_type: Token::FUNC_BUILT_IN),
      )
      execute
      expect(sore).to eq sd_array(0 => 'あ', 'ほげ' => 'き', '4.6' => 'う', 5 => 'か', 'ふが' => 'く')
    end

    it 'processes properties in simple if statements' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
        Token.new(Token::IF),
        Token.new(Token::COMP_EQ),
        Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '1', sub_type: Token::KEY_INDEX),
        Token.new(Token::QUESTION),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(sore).to eq 1
    end

    it 'processes properties in comparison if statements (comp 1 and comp 2)' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'キー名', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「hello」', sub_type: Token::VAL_STR),
        Token.new(Token::IF),
        Token.new(Token::COMP_EQ),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, 'キー名', sub_type: Token::KEY_VAR),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '「3」', sub_type: Token::KEY_NAME),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(sore).to eq 1
    end

    it 'processes properties in functional if statements ' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '1', sub_type: Token::KEY_INDEX),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
        Token.new(Token::IF),
        Token.new(Token::COMP_EQ),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::KEY_INDEX),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::SUBTRACT, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(sore).to eq 1
    end

    it 'processes properties in loops' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '10', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '15', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),
        Token.new(Token::POSSESSIVE, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::KEY_INDEX),
        Token.new(Token::POSSESSIVE, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '2', particle: 'まで', sub_type: Token::KEY_INDEX),
        Token.new(Token::LOOP),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(variable('ホゲ')).to eq 6
    end

    it 'processes properties in loop iterators' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::POSSESSIVE, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '1', sub_type: Token::KEY_INDEX),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '10', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '20', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '30', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),
        Token.new(Token::POSSESSIVE, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '1', particle: 'に', sub_type: Token::KEY_INDEX),
        Token.new(Token::LOOP_ITERATOR),
        Token.new(Token::LOOP),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'それ', particle: 'を', sub_type: Token::VAR_SORE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(variable('ホゲ')).to eq 60
    end

    it 'can return properties from functions' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'フガ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_DEF, 'ほげる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::POSSESSIVE, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '3', particle: 'を', sub_type: Token::KEY_INDEX), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_CALL, 'ほげる', sub_type: Token::FUNC_USER),
      )
      execute
      expect(sore).to eq 'う'
    end

    private

    def hoge_fuga_array_tokens
      [
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '3', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),
      ]
    end

    ##
    # Creates a mixed array: {0: "あ", "ほげ": "い", 4.6: "う"}
    def hoge_mixed_array_tokens
      [
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '1', sub_type: Token::KEY_INDEX),
        Token.new(Token::RVALUE, '「あ」', sub_type: Token::VAL_STR),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '「ほげ」', sub_type: Token::KEY_NAME),
        Token.new(Token::RVALUE, '「い」', sub_type: Token::VAL_STR),
        Token.new(Token::POSSESSIVE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ASSIGNMENT, '「4.6」', sub_type: Token::KEY_NAME),
        Token.new(Token::RVALUE, '「う」', sub_type: Token::VAL_STR),
      ]
    end
  end
end
