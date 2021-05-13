require './src/token'
require './src/interpreter/processor'
require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'if statements' do
  include_context 'processor'

  describe '#execute' do
    it 'can test all types of binary comparisons' do
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

    it 'can process empty and non-empty comparisons' do
      {
        '要素あり配列' => {
          Token::COMP_EMP  => :to_not,
          Token::COMP_NEMP => :to,
        },
        '要素なし配列' => {
          Token::COMP_EMP  => :to,
          Token::COMP_NEMP => :to_not,
        },
      }.each do |variable, tests|
        tests.each do |comparator, test_method|
          mock_lexer(
            # array with items
            Token.new(Token::ASSIGNMENT, '要素あり配列', sub_type: Token::VARIABLE),
            Token.new(Token::ARRAY_BEGIN),
            Token.new(Token::RVALUE, '「あ」', sub_type: Token::VAL_STR), Token.new(Token::COMMA),
            Token.new(Token::RVALUE, '「い」', sub_type: Token::VAL_STR), Token.new(Token::COMMA),
            Token.new(Token::RVALUE, '「う」', sub_type: Token::VAL_STR),
            Token.new(Token::ARRAY_CLOSE),
            # array with on items
            Token.new(Token::ASSIGNMENT, '要素なし配列', sub_type: Token::VARIABLE),
            Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
            # if statement
            Token.new(Token::IF),
            Token.new(comparator),
            Token.new(Token::RVALUE, variable, sub_type: Token::VARIABLE),
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

    it 'can process inside and not-inside conditions' do
      {
        Token::COMP_IN  => :to,
        Token::COMP_NIN => :to_not,
      }.each do |comparator, test_method|
        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
          Token.new(Token::ARRAY_BEGIN),
          Token.new(Token::RVALUE, '「あ」', sub_type: Token::VAL_STR), Token.new(Token::COMMA),
          Token.new(Token::RVALUE, '「い」', sub_type: Token::VAL_STR), Token.new(Token::COMMA),
          Token.new(Token::RVALUE, '「う」', sub_type: Token::VAL_STR),
          Token.new(Token::ARRAY_CLOSE),
          Token.new(Token::IF),
          Token.new(comparator),
          Token.new(Token::RVALUE, '「あ」', sub_type: Token::VAL_STR),
          Token.new(Token::RVALUE, 'ホゲ', sub_type: Token::VARIABLE),
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

    it 'evaluates AND correctly' do
      [
        [false, false],
        [false, true],
        [true, false],
        [true, true],
      ].each do |(cond1, cond2)|
        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
          Token.new(Token::RVALUE, '偽', sub_type: Token::VAL_FALSE),
          Token.new(Token::IF),
          *condition(cond1),
          Token.new(Token::COMMA),
          Token.new(Token::AND),
          *condition(cond2),
          Token.new(Token::SCOPE_BEGIN),
          Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
          Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
          Token.new(Token::SCOPE_CLOSE),
        )
        execute
        expect(sore).to eq cond1 && cond2
      end
    end

    it 'evaluates OR correctly' do
      [
        [false, false],
        [false, true],
        [true, false],
        [true, true],
      ].each do |(cond1, cond2)|
        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
          Token.new(Token::RVALUE, '偽', sub_type: Token::VAL_FALSE),
          Token.new(Token::IF),
          *condition(cond1),
          Token.new(Token::COMMA),
          Token.new(Token::OR),
          *condition(cond2),
          Token.new(Token::SCOPE_BEGIN),
          Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
          Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
          Token.new(Token::SCOPE_CLOSE),
        )
        execute
        expect(sore).to eq cond1 || cond2
      end
    end

    it 'overwrites それ in subsequent functional conditions' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM),
        Token.new(Token::IF),
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
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(sore).to eq 3
    end

    it 'short-circuits AND' do
      {
        true => 1, # first condition is true, evaluate second condition
        false => 0, # first condition is false, skip evaluating second condition
      }.each do |condition, expected_sore|
        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
          Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM),
          Token.new(Token::IF),
          *condition(condition),
          Token.new(Token::COMMA),
          Token.new(Token::AND),
          Token.new(Token::COMP_EQ),
          Token.new(Token::PARAMETER, 'それ', particle: 'に', sub_type: Token::VAR_SORE),
          Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
          Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, sub_type: Token::FUNC_BUILT_IN),
          Token.new(Token::SCOPE_BEGIN),
          Token.new(Token::SCOPE_CLOSE),
        )
        execute
        expect(sore).to eq expected_sore
      end
    end

    it 'short-circuits OR' do
      {
        false => 1, # first condition is false, evaluate second condition
        true => 0, # first condition is true, skip evaluating second condition
      }.each do |condition, expected_sore|
        mock_lexer(
          Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
          Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM),
          Token.new(Token::IF),
          *condition(condition),
          Token.new(Token::COMMA),
          Token.new(Token::OR),
          Token.new(Token::COMP_EQ),
          Token.new(Token::PARAMETER, 'それ', particle: 'に', sub_type: Token::VAR_SORE),
          Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
          Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, sub_type: Token::FUNC_BUILT_IN),
          Token.new(Token::SCOPE_BEGIN),
          Token.new(Token::SCOPE_CLOSE),
        )
        execute
        expect(sore).to eq expected_sore
      end
    end

    private

    def condition(is_true)
      [
        Token.new(Token::COMP_EQ),
        Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
        Token.new(Token::RVALUE, '', sub_type: (is_true ? Token::VAL_TRUE : Token::VAL_FALSE)),
      ]
    end
  end
end
