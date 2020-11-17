require './src/token'
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
      expect(variable('ピヨ')).to eq [true, true]
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
        Token.new(Token::FUNCTION_CALL, '足す', sub_type: Token::FUNC_BUILT_IN),
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
        Token.new(Token::FUNCTION_CALL, '足す', sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::ASSIGNMENT, 'ピヨ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(variable('ピヨ')).to eq 2
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
  end
end
