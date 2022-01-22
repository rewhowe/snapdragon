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

    it 'can process if array and not-if array conditions' do
      {
          Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY) => {
            Token::COMP_EQ  => :to,
            Token::COMP_NEQ => :to_not,
          },
          Token.new(Token::RVALUE, '「文字列は配列じゃない」', sub_type: Token::VAL_STR) => {
            Token::COMP_EQ  => :to_not,
            Token::COMP_NEQ => :to,
          },
      }.each do |token, tests|
        tests.each do |comparator, test_method|
          mock_lexer(
            Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
            token,
            Token.new(Token::IF),
            Token.new(comparator),
            Token.new(Token::RVALUE, 'ホゲ', sub_type: Token::VARIABLE),
            Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
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

    # AND with higher precedence:
    # 0 & 1 | 1
    #     0 | 1
    #         1
    #
    # If OR had higher precednence:
    # 0 & 1 | 1
    # 0 &     1
    # 0
    it 'evaluates AND with higher precedence (1)' do
      # もし 偽？、且つ 真？、又は 真？ ならば
      mock_lexer(
        Token.new(Token::IF),
        *condition(false),
        Token.new(Token::COMMA),
        Token.new(Token::AND),
        *condition(true),
        Token.new(Token::COMMA),
        Token.new(Token::OR),
        *condition(true),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(sore).to eq 1
    end

    # AND with higher precedence:
    # 1 | 0 & 0 | 0
    # 1 | 0     | 0
    # 1
    #
    # If OR had higher precednence:
    # 1 | 0 & 0 | 0
    # 1     & 0
    #         0
    it 'evaluates AND with higher precedence (2)' do
      # もし 真？、又は 偽？、且つ 偽？、又は 偽？ ならば
      mock_lexer(
        Token.new(Token::IF),
        *condition(true),
        Token.new(Token::COMMA),
        Token.new(Token::OR),
        *condition(false),
        Token.new(Token::COMMA),
        Token.new(Token::AND),
        *condition(false),
        Token.new(Token::COMMA),
        Token.new(Token::OR),
        *condition(false),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::ASSIGNMENT, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(sore).to eq 1
    end

    # # A == B && C >= D || E != F && (G || !H)
    # G_or_not_Hるとは
    # 　もし G?、または H? でなければ
    # 　　はいと なる
    # 結果は 偽
    # もし Aが Bと 同じ で、且つ Cが D以上 で、
    # 又は Eが Fと 同じ でなく、且つ G_or_not_Hる？ ならば
    # 　結果は 真
    it 'can evaluate complex boolean expressions' do
      [0, 1].each do |a|
        [0, 1].each do |b|
          [0, 1].each do |c|
            [0, 1].each do |d|
              [0, 1].each do |e|
                [0, 1].each do |f|
                  [true, false].each do |g|
                    [true, false].each do |h|
                      mock_lexer(
                        # define helper function
                        Token.new(Token::FUNCTION_DEF, 'G_or_not_Hる'),
                        Token.new(Token::SCOPE_BEGIN),
                        Token.new(Token::IF),
                        *condition(g),
                        Token.new(Token::COMMA),
                        Token.new(Token::OR),
                        Token.new(Token::COMP_NEQ),
                        Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
                        Token.new(Token::RVALUE, '', sub_type: (h ? Token::VAL_TRUE : Token::VAL_FALSE)),
                        Token.new(Token::SCOPE_BEGIN),
                        Token.new(Token::PARAMETER, '真', particle: 'と', sub_type: Token::VAL_TRUE),
                        Token.new(Token::RETURN),
                        Token.new(Token::SCOPE_CLOSE),
                        Token.new(Token::PARAMETER, '無', particle: 'を', sub_type: Token::VAL_NULL),
                        Token.new(Token::RETURN),
                        Token.new(Token::SCOPE_CLOSE),
                        # initial value for result (false)
                        Token.new(Token::ASSIGNMENT, '結果', sub_type: Token::VARIABLE),
                        Token.new(Token::RVALUE, '偽', sub_type: Token::VAL_FALSE),
                        # main if statement
                        Token.new(Token::IF),
                        # A == B
                        Token.new(Token::COMP_EQ),
                        Token.new(Token::RVALUE, a.to_s, sub_type: Token::VAL_NUM),
                        Token.new(Token::RVALUE, b.to_s, sub_type: Token::VAL_NUM),
                        Token.new(Token::COMMA),
                        # && C >= D
                        Token.new(Token::AND),
                        Token.new(Token::COMP_GTEQ),
                        Token.new(Token::RVALUE, c.to_s, sub_type: Token::VAL_NUM),
                        Token.new(Token::RVALUE, d.to_s, sub_type: Token::VAL_NUM),
                        Token.new(Token::COMMA),
                        # || E != F
                        Token.new(Token::OR),
                        Token.new(Token::COMP_NEQ),
                        Token.new(Token::RVALUE, e.to_s, sub_type: Token::VAL_NUM),
                        Token.new(Token::RVALUE, f.to_s, sub_type: Token::VAL_NUM),
                        Token.new(Token::COMMA),
                        # && (G || !H)
                        Token.new(Token::AND),
                        Token.new(Token::COMP_EQ),
                        Token.new(Token::FUNCTION_CALL, 'G_or_not_Hる', sub_type: Token::FUNC_USER),
                        Token.new(Token::SCOPE_BEGIN),
                        # if the entire condition is true, set result to true
                        Token.new(Token::ASSIGNMENT, '結果', sub_type: Token::VARIABLE),
                        Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE),
                        Token.new(Token::SCOPE_CLOSE),
                      )
                      execute
                      expected_result = (a == b && c >= d || e != f && (g || !h))
                      expect(variable('結果')).to(
                        eq(expected_result),
                        "expected #{expected_result} (#{a} == #{b} && #{c} >= #{d} || #{e} !== #{f} && (#{g} || #{!h}))"
                      )
                    end
                  end
                end
              end
            end
          end
        end
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
