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

    %i[if else_if else].each do |test|
      it "performs the #{test} body if true and skips the other branches" do
        true_token = Token.new Token::RVALUE, '真', sub_type: Token::VAL_TRUE
        false_token = Token.new Token::RVALUE, '偽', sub_type: Token::VAL_FALSE

        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'executed_if', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, 'いいえ', sub_type: Token::VAL_FALSE),
          Token.new(Token::ASSIGNMENT, 'executed_else_if', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, 'いいえ', sub_type: Token::VAL_FALSE),
          Token.new(Token::ASSIGNMENT, 'executed_else', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, 'いいえ', sub_type: Token::VAL_FALSE),
          Token.new(Token::IF),
          Token.new(Token::COMP_EQ),
          Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
          test == :if ? true_token : false_token,
          Token.new(Token::SCOPE_BEGIN),
          Token.new(Token::ASSIGNMENT, 'executed_if', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, 'はい', sub_type: Token::VAL_TRUE),
          Token.new(Token::SCOPE_CLOSE),
          Token.new(Token::ELSE_IF),
          Token.new(Token::COMP_EQ),
          Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
          test == :else_if ? true_token : false_token,
          Token.new(Token::SCOPE_BEGIN),
          Token.new(Token::ASSIGNMENT, 'executed_else_if', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, 'はい', sub_type: Token::VAL_TRUE),
          Token.new(Token::SCOPE_CLOSE),
          Token.new(Token::ELSE),
          Token.new(Token::SCOPE_BEGIN),
          Token.new(Token::ASSIGNMENT, 'executed_else', sub_type: Token::VARIABLE),
          Token.new(Token::RVALUE, 'はい', sub_type: Token::VAL_TRUE),
          Token.new(Token::SCOPE_CLOSE),
        )
        execute
        expect(variable('executed_if')).to eq test == :if
        expect(variable('executed_else_if')).to eq test == :else_if
        expect(variable('executed_else')).to eq test == :else
      end
    end

    it 'can process variables defined in an if block, outside of said block' do
      mock_lexer(
        Token.new(Token::IF),
        Token.new(Token::COMP_EQ),
        Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
        Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'ホゲ', sub_type: Token::VARIABLE),
      )
      expect { execute } .to_not raise_error
      expect(variable('フガ')).to eq 1
    end

    it 'can process calls to function defined in an if block, outside of said block' do
      mock_lexer(
        Token.new(Token::IF),
        Token.new(Token::COMP_EQ),
        Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
        Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::FUNCTION_DEF, 'ほげる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::FUNCTION_CALL, 'ほげる', sub_type: Token::FUNC_USER),
      )
      expect { execute } .to_not raise_error
      expect(sore).to eq 1
    end

    it 'immediately returns false for comparisons between rvalues of different types' do
      mock_lexer(
        Token.new(Token::IF),
        Token.new(Token::COMP_GT),
        Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::SCOPE_CLOSE),
      )
      expect { execute } .to_not raise_error
      expect(sore).to_not eq 1
    end
  end
end
