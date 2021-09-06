require './src/token'
require './src/tokenizer/built_ins'
require './src/interpreter/processor'
require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'while loops' do
  include_context 'processor'

  # Core functionality is shared by if statements and regular loops.
  describe '#execute' do
    it 'will not enter a loop with a false condition' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM),
        Token.new(Token::WHILE),
        Token.new(Token::COMP_EQ),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
        Token.new(Token::LOOP, '繰り返す'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(variable('ホゲ')).to eq 0
    end

    it 'modifies condition variables' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM),
        Token.new(Token::WHILE),
        Token.new(Token::COMP_LT),
        Token.new(Token::RVALUE, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '10', sub_type: Token::VAL_NUM),
        Token.new(Token::LOOP, '繰り返す'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(variable('ホゲ')).to eq 10
    end

    it 'carries sore across conditions and iterations' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, '回数', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM),
        Token.new(Token::WHILE),
        Token.new(Token::COMP_EQ),
        Token.new(Token::PARAMETER, 'それ', particle: 'に', sub_type: Token::VAR_SORE),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::COMMA),
        Token.new(Token::AND),
        Token.new(Token::COMP_EQ),
        Token.new(Token::PARAMETER, 'それ', particle: 'に', sub_type: Token::VAR_SORE),
        Token.new(Token::PARAMETER, '2', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::COMMA),
        Token.new(Token::AND),
        Token.new(Token::COMP_LT),
        Token.new(Token::RVALUE, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::RVALUE, '10', sub_type: Token::VAL_NUM),
        Token.new(Token::LOOP, '繰り返す'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::NO_OP),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(sore).to eq 12
    end
  end
end
