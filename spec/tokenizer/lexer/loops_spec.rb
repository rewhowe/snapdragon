require './src/token'
require './src/tokenizer/lexer'
require './spec/contexts/lexer'

include Tokenizer

RSpec.describe Lexer, 'loops' do
  include_context 'lexer'

  describe '#next_token' do
    it 'tokenizes basic loops' do
      mock_reader(
        "繰り返す\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes loops over ranges' do
      mock_reader(
        "1から 100まで 繰り返す\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::PARAMETER, '100', Token::VAL_NUM],
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes loops over collections' do
      mock_reader(
        "友達は 「ジャック」、「ウイ」、「チャールズ」\n" \
        "友達に 対して 繰り返す\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::ASSIGNMENT, '友達', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::RVALUE, '「ジャック」', Token::VAL_STR], [Token::COMMA],
        [Token::RVALUE, '「ウイ」', Token::VAL_STR], [Token::COMMA],
        [Token::RVALUE, '「チャールズ」', Token::VAL_STR],
        [Token::ARRAY_CLOSE],
        [Token::PARAMETER, '友達', Token::VARIABLE],
        [Token::LOOP_ITERATOR],
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes loops over strings' do
      mock_reader(
        "「あいうえお」に 対して 繰り返す\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::PARAMETER, '「あいうえお」', Token::VAL_STR],
        [Token::LOOP_ITERATOR],
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes while loops with truthy conditions' do
      {
        '真の' => Token::VAL_TRUE,
        '偽の' => Token::VAL_FALSE,
      }.each do |keyword, boolean_sub_type|
        mock_reader(
          "それ？ #{keyword} 限り 繰り返す\n" \
          "　・・・\n"
        )

        expect(tokens).to contain_exactly_in_order(
          [Token::WHILE],
          [Token::COMP_EQ],
          [Token::RVALUE, keyword.chomp('の'), boolean_sub_type],
          [Token::RVALUE, 'それ', Token::VAR_SORE],
          [Token::QUESTION],
          [Token::LOOP],
          [Token::SCOPE_BEGIN],
          [Token::NO_OP],
          [Token::SCOPE_CLOSE],
        )
      end
    end

    it 'tokenizes while loops with functional conditions' do
      {
        '足す' => Token::COMP_EQ,
        '足して ない' => Token::COMP_NEQ,
      }.each do |keywords, token_type|
        mock_reader(
          "1を #{keywords} 限り 繰り返す\n" \
          "　・・・\n"
        )

        expect(tokens).to contain_exactly_in_order(
          [Token::WHILE],
          [token_type],
          [Token::PARAMETER, 'それ', Token::VAR_SORE],
          [Token::PARAMETER, '1', Token::VAL_NUM],
          [Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, Token::FUNC_BUILT_IN],
          [Token::LOOP],
          [Token::SCOPE_BEGIN],
          [Token::NO_OP],
          [Token::SCOPE_CLOSE],
        )
      end
    end

    it 'tokenizes while loops with == and != conditions' do
      {
        '0 である' => Token::COMP_EQ,
        '0と 同じ でない' => Token::COMP_NEQ,
      }.each do |keywords, token_type|
        mock_reader(
          "1が #{keywords} 限り 繰り返す\n" \
          "　・・・\n"
        )
        expect(tokens).to contain_exactly_in_order(
          [Token::WHILE],
          [token_type],
          [Token::RVALUE, '1', Token::VAL_NUM],
          [Token::RVALUE, '0', Token::VAL_NUM],
          [Token::LOOP],
          [Token::SCOPE_BEGIN],
          [Token::NO_OP],
          [Token::SCOPE_CLOSE],
        )
      end
    end

    it 'tokenizes while loops with < and > conditions' do
      {
        '小さい' => Token::COMP_LT,
        '大きい' => Token::COMP_GT,
      }.each do |keyword, token_type|
        mock_reader(
          "1が 0より #{keyword} 限り 繰り返す\n" \
          "　・・・\n"
        )
        expect(tokens).to contain_exactly_in_order(
          [Token::WHILE],
          [token_type],
          [Token::RVALUE, '1', Token::VAL_NUM],
          [Token::RVALUE, '0', Token::VAL_NUM],
          [Token::LOOP],
          [Token::SCOPE_BEGIN],
          [Token::NO_OP],
          [Token::SCOPE_CLOSE],
        )
      end
    end

    it 'tokenizes while loops with in and nin conditions' do
      {
        'ある' => Token::COMP_IN,
        'ない' => Token::COMP_NIN,
      }.each do |keyword, token_type|
        mock_reader(
          "1が それの 中に #{keyword} 限り 繰り返す\n" \
          "　・・・\n"
        )
        expect(tokens).to contain_exactly_in_order(
          [Token::WHILE],
          [token_type],
          [Token::RVALUE, '1', Token::VAL_NUM],
          [Token::RVALUE, 'それ', Token::VAR_SORE],
          [Token::LOOP],
          [Token::SCOPE_BEGIN],
          [Token::NO_OP],
          [Token::SCOPE_CLOSE],
        )
      end
    end

    it 'tokenizes while loops with multiple conditions' do
      mock_reader(
        "それ？、且つ 1に 2を 足して、又は それが 空 である 限り 繰り返す\n" \
        "　・・・\n"
      )
      expect(tokens).to contain_exactly_in_order(
        [Token::WHILE],
        [Token::COMP_EQ],
        [Token::RVALUE, '真', Token::VAL_TRUE],
        [Token::RVALUE, 'それ', Token::VAR_SORE],
        [Token::QUESTION],
        [Token::COMMA],
        [Token::AND],
        [Token::COMP_EQ],
        [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::PARAMETER, '2', Token::VAL_NUM],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, Token::FUNC_BUILT_IN],
        [Token::COMMA],
        [Token::OR],
        [Token::COMP_EMP],
        [Token::RVALUE, 'それ', Token::VAR_SORE],
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes next keyword in loops' do
      mock_reader(
        "繰り返す\n" \
        "　次\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::NEXT],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes break keyword in loops' do
      mock_reader(
        "繰り返す\n" \
        "　終わり\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::BREAK],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes break and next keywords nested in loops' do
      mock_reader(
        "繰り返す\n" \
        "　もし 1が 1 ならば\n" \
        "　　次\n" \
        "　違えば\n" \
        "　　終わり\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::IF],
        [Token::COMP_EQ],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::SCOPE_BEGIN],
        [Token::NEXT],
        [Token::SCOPE_CLOSE],
        [Token::ELSE],
        [Token::SCOPE_BEGIN],
        [Token::BREAK],
        [Token::SCOPE_CLOSE],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes usage of variables defined in a loop, outside of said loop' do
      mock_reader(
        "繰り返す\n" \
        "　ホゲは 1\n" \
        "　終わり\n" \
        "フガは ホゲ\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE], [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::BREAK],
        [Token::SCOPE_CLOSE],
        [Token::ASSIGNMENT, 'フガ', Token::VARIABLE], [Token::RVALUE, 'ホゲ', Token::VARIABLE],
      )
    end
  end
end
