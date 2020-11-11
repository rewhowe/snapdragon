require './src/token'
require './src/interpreter/processor'
require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'if statements' do
  include_context 'processor'

  describe '#execute' do
    it 'can test all types of conditions' do
      {
        Token::COMP_LT   => [[:to, '0', '1'],                  [:to_not, '1', '0']],
        Token::COMP_LTEQ => [[:to, '0', '1'], [:to, '1', '1'], [:to_not, '1', '0']],
        Token::COMP_EQ   => [[:to, '1', '1'],                  [:to_not, '1', '0']],
        Token::COMP_NEQ  => [[:to, '1', '0'],                  [:to_not, '1', '1']],
        Token::COMP_GTEQ => [[:to, '1', '0'], [:to, '1', '1'], [:to_not, '0', '1']],
        Token::COMP_GT   => [[:to, '1', '0'],                  [:to_not, '0', '1']],
      }.each do |comparator, tests|
        tests.each do |(test_method, comp1, comp2)|
          mock_lexer(
            Token.new(Token::IF),
            Token.new(comparator),
            Token.new(Token::RVALUE, comp1, sub_type: Token::VAL_NUM),
            Token.new(Token::RVALUE, comp2, sub_type: Token::VAL_NUM),
            Token.new(Token::SCOPE_BEGIN),
            Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
            Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
            Token.new(Token::SCOPE_CLOSE),
          )
          execute
          expect(sore).send test_method, eq(1)
        end
      end
    end

    it 'can test boolean-cast conditions' do
      {
        Token::COMP_EQ  => { to: '1', to_not: '0' },
        Token::COMP_NEQ => { to: '0', to_not: '1' },
      }.each do |comparator, tests|
        tests.each do |test_method, test_variable|
          mock_lexer(
            Token.new(Token::IF),
            Token.new(comparator),
            Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
            Token.new(Token::RVALUE, test_variable, sub_type: Token::VAL_NUM),
            Token.new(Token::QUESTION),
            Token.new(Token::SCOPE_BEGIN),
            Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
            Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
            Token.new(Token::SCOPE_CLOSE),
          )
          execute
          expect(sore).send test_method, eq(1)
        end
      end
    end

    it 'can call functions as test conditions' do
      {
        Token::COMP_EQ  => :to,
        Token::COMP_NEQ => :to_not,
      }.each do |comparator, test_method|
        mock_lexer(
          Token.new(Token::FUNCTION_DEF, 'ほげる'),
          Token.new(Token::SCOPE_BEGIN),
          Token.new(Token::PARAMETER, '真', particle: 'を', sub_type: Token::VAL_TRUE), Token.new(Token::RETURN),
          Token.new(Token::SCOPE_CLOSE),
          Token.new(Token::IF),
          Token.new(comparator),
          Token.new(Token::FUNCTION_CALL, 'ほげる', sub_type: Token::FUNC_USER),
          Token.new(Token::SCOPE_BEGIN),
          Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
          Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
          Token.new(Token::SCOPE_CLOSE),
        )
        execute
        expect(sore).send test_method, eq(1)
      end
    end
  end
end
