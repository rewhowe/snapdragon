require './src/token'
require './src/interpreter/processor'
require './src/interpreter/scope'
require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'functions' do
  include_context 'processor'

  describe '#execute' do
    it 'can define a function' do
      mock_lexer(
        Token.new(Token::FUNCTION_DEF, 'ほげる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, '無', particle: 'を', sub_type: Token::VAL_NULL), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(function('ほげる')).to be_instance_of Interpreter::Scope
    end

    it 'can call a function' do
      mock_lexer(
        Token.new(Token::FUNCTION_DEF, 'ほげる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, '無', particle: 'を', sub_type: Token::VAL_NULL), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::FUNCTION_CALL, 'ほげる'),
      )
      expect { execute } .to_not raise_error
    end

    it 'can define a function with parameters' do
      mock_lexer(
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'と', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'フガ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_DEF, 'ほげる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, '無', particle: 'を', sub_type: Token::VAL_NULL), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(function('ほげるとを')).to be_instance_of Interpreter::Scope
    end

    it 'can call a function with parameters' do
      mock_lexer(
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'と', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'フガ', particle: 'を', sub_type: Token::VARIABLE),
        Token.new(Token::FUNCTION_DEF, 'ほげる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, '無', particle: 'を', sub_type: Token::VAL_NULL), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::PARAMETER, '1', particle: 'と', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '2', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, 'ほげる'),
      )
      expect { execute } .to_not raise_error
    end

    it 'sets the return value of a function to それ' do
      mock_lexer(
        Token.new(Token::FUNCTION_DEF, 'ほげる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::FUNCTION_CALL, 'ほげる'),
      )
      execute
      expect(sore).to eq 1
    end

    it 'can read outer-scoped variables inside functions' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '5', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_DEF, 'ほげる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::FUNCTION_CALL, 'ほげる'),
      )
      execute
      expect(sore).to eq 5
    end

    it 'cannot modify variables from outer-scopes inside functions' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '5', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_DEF, 'ほげる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '10', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'を', sub_type: Token::VARIABLE), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::FUNCTION_CALL, 'ほげる'),
      )
      execute
      expect(sore).to eq 10
      expect(variable('ホゲ')).to eq 5
    end

    it 'can call outer-scope functions inside functions' do
      mock_lexer(
        Token.new(Token::FUNCTION_DEF, 'ほげる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, '5', particle: 'を', sub_type: Token::VAL_NUM), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::FUNCTION_DEF, 'ふがる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::FUNCTION_CALL, 'ほげる'),
        Token.new(Token::PARAMETER, 'それ', particle: 'を', sub_type: Token::VAR_SORE), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::FUNCTION_CALL, 'ふがる'),
      )
      execute
      expect(sore).to eq 5
    end

    it 'can call functions defined inside functions' do
      mock_lexer(
        Token.new(Token::FUNCTION_DEF, 'ふがる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::FUNCTION_DEF, 'ほげる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, '5', particle: 'を', sub_type: Token::VAL_NUM), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::FUNCTION_CALL, 'ほげる'),
        Token.new(Token::PARAMETER, 'それ', particle: 'を', sub_type: Token::VAR_SORE), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::FUNCTION_CALL, 'ふがる'),
      )
      execute
      expect(sore).to eq 5
    end
  end
end
