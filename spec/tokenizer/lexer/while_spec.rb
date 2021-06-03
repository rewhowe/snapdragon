require './src/token'
require './src/tokenizer/lexer'
require './spec/contexts/lexer'

include Tokenizer

RSpec.describe Lexer, 'while loops' do
  include_context 'lexer'

  describe '#next_token' do
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
  end
end
