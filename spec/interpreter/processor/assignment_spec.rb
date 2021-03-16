require './src/token'
require './src/interpreter/processor'
require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'assignment' do
  include_context 'processor'

  describe '#execute' do
    it 'can assign all sorts of primitives to a variable' do
      {
        ['1',      Token::VAL_NUM] => 1,
        ['「あ」', Token::VAL_STR] => 'あ',
        ['正',     Token::VAL_TRUE] => true,
        ['偽',     Token::VAL_FALSE] => false,
        ['無',     Token::VAL_NULL] => nil,
        ['配列',   Token::VAL_ARRAY] => sd_array,
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

    it 'can assign arrays' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '3', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),
      )
      execute
      expect(variable('ホゲ')).to eq sd_array [1.0, 2.0, 3.0]
    end

    it 'can boolean cast all types of values' do
      {
        ['0',      Token::VAL_NUM] => false,
        ['1',      Token::VAL_NUM] => true,
        ['「」',   Token::VAL_STR] => false,
        ['「あ」', Token::VAL_STR] => true,
        ['偽',     Token::VAL_FALSE] => false,
        ['正',     Token::VAL_TRUE] => true,
        ['無',     Token::VAL_NULL] => false,
      } .each do |(token_value, token_sub_type), variable_value|
        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, token_value, sub_type: token_sub_type),
          Token.new(Token::QUESTION),
        )
        execute
        expect(variable('ホゲ')).to eq variable_value
      end

      mock_lexer(
        # empty array
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::QUESTION),
        # array with items
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '3', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::QUESTION),
      )
      execute
      expect(variable('ホゲ')).to eq false
      expect(variable('フガ')).to eq true
    end

    it 'can boolean cast array elements' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM), Token.new(Token::QUESTION), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::QUESTION), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '「」', sub_type: Token::VAL_STR), Token.new(Token::QUESTION), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '「あ」', sub_type: Token::VAL_STR),
        Token.new(Token::QUESTION),
        Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::QUESTION),
        Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '偽', sub_type: Token::VAL_FALSE), Token.new(Token::QUESTION), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '正', sub_type: Token::VAL_TRUE), Token.new(Token::QUESTION), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '無', sub_type: Token::VAL_NULL), Token.new(Token::QUESTION), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::QUESTION),
        Token.new(Token::COMMA),
        Token.new(Token::ARRAY_CLOSE),
      )
      execute
      expectation = sd_array [false, true, false, true, false, false, true, false, true]

      expect(variable('ホゲ')).to eq expectation
    end

    it 'recognizes various forms of escaping across multiline strings' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「「おっはー！\\」ということ\\\\n」', sub_type: Token::VAL_STR),
      )
      execute
      expect(variable('ホゲ')).to eq '「おっはー！」ということ\\n'
    end

    it 'recognizes triply-escaping 」 in strings (and 5, 7, etc...)' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「「おっはー！\\\\\\」ということ」', sub_type: Token::VAL_STR),
      )
      execute
      expect(variable('ホゲ')).to eq '「おっはー！\\」ということ'
    end

    it 'can resolve interpolated strings' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「1【ホゲ】3」', sub_type: Token::VAL_STR),
      )
      execute
      expect(variable('フガ')).to eq '123'
    end

    it 'can resolve doubly-escaped interpolated strings' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「1\\\\【ホゲ】3」', sub_type: Token::VAL_STR),
      )
      execute
      expect(variable('フガ')).to eq '123'
    end

    it 'will not resolve escaped interpolation in strings' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「1\【ホゲ】3」', sub_type: Token::VAL_STR),
      )
      execute
      expect(variable('ホゲ')).to eq '1【ホゲ】3'
    end

    it 'will not resolve triply-escaped interpolation in strings' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「1\\\\\【ホゲ】3」', sub_type: Token::VAL_STR),
      )
      execute
      expect(variable('ホゲ')).to eq '1\\【ホゲ】3'
    end

    it 'recognizes various forms of escaping across multiline strings' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「「おっはー！\\」ということ\\\\n」', sub_type: Token::VAL_STR),
      )
      execute
      expect(variable('ホゲ')).to eq '「おっはー！」ということ\\n'
    end

    it 'recognizes triply-escaping 」 in strings (and 5, 7, etc...)' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「「おっはー！\\\\\\」ということ」', sub_type: Token::VAL_STR),
      )
      execute
      expect(variable('ホゲ')).to eq '「おっはー！\\」ということ'
    end

    it 'can resolve interpolated strings' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「1【ホゲ】3」', sub_type: Token::VAL_STR),
      )
      execute
      expect(variable('フガ')).to eq '123'
    end

    it 'can resolve doubly-escaped interpolated strings' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「1\\\\【ホゲ】3」', sub_type: Token::VAL_STR),
      )
      execute
      expect(variable('フガ')).to eq '123'
    end

    it 'will not resolve escaped interpolation in strings' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「1\【ホゲ】3」', sub_type: Token::VAL_STR),
      )
      execute
      expect(variable('ホゲ')).to eq '1【ホゲ】3'
    end

    it 'will not resolve triply-escaped interpolation in strings' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「1\\\\\【ホゲ】3」', sub_type: Token::VAL_STR),
      )
      execute
      expect(variable('ホゲ')).to eq '1\\【ホゲ】3'
    end
  end
end
