require './src/token'
require './src/tokenizer/built_ins'
require './src/interpreter/processor'
require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'properties' do
  include_context 'processor'

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

    # TODO: feature/associative-arrays
    # it 'can interpolate a string with property key index' do
    # end
    #
    # it 'can interpolate a string with property key name' do
    # end
    #
    # it 'can interpolate a string with property key variable' do
    # end
  end
end
