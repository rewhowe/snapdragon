require './src/token'
require './src/interpreter/processor'
require './spec/contexts/interpreter'

RSpec.describe Interpreter::Processor, 'assignment' do
  include_context 'interpreter'

  describe '#process' do
    it 'can assign all sorts of primitives to a variable' do
      {
        ['1',      Token::VAL_NUM] => 1,
        ['「あ」', Token::VAL_STR] => 'あ',
        ['正',     Token::VAL_TRUE] => true,
        ['偽',     Token::VAL_FALSE] => false,
        ['無',     Token::VAL_NULL] => nil,
        ['配列',   Token::VAL_ARRAY] => [],
      } .each do |(token_value, token_sub_type), variable_value|
        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, token_value, sub_type: token_sub_type),
        )
        execute
        expect(variable('ホゲ')).to eq variable_value
      end
    end

    it 'can assign variables to one another' do
      {
        'フガ' => Token::VARIABLE,
        'それ' => Token::VAR_SORE,
        'あれ' => Token::VAR_ARE,
      } .each do |variable_name, variable_sub_type|
        mock_lexer(
          Token.new(Token::ASSIGNMENT, variable_name, sub_type: variable_sub_type),
          Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
          Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, variable_name, sub_type: variable_sub_type),
        )
        execute
        expect(variable('ホゲ')).to eq 1
      end
    end
  end
end
