require './src/token'
require './src/tokenizer/lexer'
require './spec/contexts/lexer'

include Tokenizer

RSpec.describe Lexer, 'assignment' do
  include_context 'lexer'

  describe '#next_token' do
    it 'tokenizes variable declarations' do
      mock_reader(
        "ほげは 10\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE], [Token::RVALUE, '10', Token::VAL_NUM],
      )
    end

    it 'can assign variables to other variables' do
      mock_reader(
        "ほげは 10\n" \
        "ふがは ほげ\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE], [Token::RVALUE, '10', Token::VAL_NUM],
        [Token::ASSIGNMENT, 'ふが', Token::VARIABLE], [Token::RVALUE, 'ほげ', Token::VARIABLE],
      )
    end

    it 'can declare variables that look like else-if' do
      mock_reader(
        "または 1\n" \
        "もしくは 2\n"
      )
      expect(tokens).to contain_exactly_in_order(
        [Token::ASSIGNMENT, 'また', Token::VARIABLE], [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::ASSIGNMENT, 'もしく', Token::VARIABLE], [Token::RVALUE, '2', Token::VAL_NUM],
      )
    end

    it 'can declare strange but valid variable names' do
      %w[
        「文字列」の
        ~ @ # $ % ^ & * ) - _ = + [ { ] } | ￥
        : ; ' " < . > /
        N-1 N:1 N#1
        🍎
        〠
        ´・ω・｀
      ].each do |name|
        mock_reader(
          "#{name}は 1\n"
        )
        expect(tokens).to contain_exactly_in_order(
          [Token::ASSIGNMENT, name, Token::VARIABLE], [Token::RVALUE, '1', Token::VAL_NUM],
        )
      end
    end

    it 'combines multiline arrays' do
      mock_reader(
        "ハイレツは 1、\n" \
        "           2、\n" \
        "           3  \n"
      )
      expect(tokens).to contain_exactly_in_order(
        [Token::ASSIGNMENT, 'ハイレツ', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::RVALUE, '1', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '2', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '3', Token::VAL_NUM],
        [Token::ARRAY_CLOSE],
      )
    end

    it 'combines multiline arrays with backslash line break alignment' do
      mock_reader(
        "ハイレツは\\\n" \
        "　1、\n" \
        "　2、\n" \
        "　3  \n"
      )
      expect(tokens).to contain_exactly_in_order(
        [Token::ASSIGNMENT, 'ハイレツ', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::RVALUE, '1', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '2', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '3', Token::VAL_NUM],
        [Token::ARRAY_CLOSE],
      )
    end

    it 'combines multiline arrays with multiline strings' do
      mock_reader(
        "魔法の言葉は 「こんにち　わん」、\n" \
        "             「ありがと　ウサギ  \n" \
        "               こんばん　ワニ    \n" \
        "              」、               \n" \
        "             「さような ライオン」\n"
      )
      expect(tokens).to contain_exactly_in_order(
        [Token::ASSIGNMENT, '魔法の言葉', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::RVALUE, '「こんにち　わん」', Token::VAL_STR], [Token::COMMA],
        [Token::RVALUE, '「ありがと　ウサギこんばん　ワニ」', Token::VAL_STR], [Token::COMMA],
        [Token::RVALUE, '「さような ライオン」', Token::VAL_STR],
        [Token::ARRAY_CLOSE],
      )
    end

    it 'tokenizes questions in array definitions' do
      mock_reader(
        "条件列は 1?, はい？、配列？、それ？\n"
      )
      expect(tokens).to contain_exactly_in_order(
        [Token::ASSIGNMENT, '条件列', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::RVALUE, '1', Token::VAL_NUM], [Token::QUESTION], [Token::COMMA],
        [Token::RVALUE, 'はい', Token::VAL_TRUE], [Token::QUESTION], [Token::COMMA],
        [Token::RVALUE, '配列', Token::VAL_ARRAY], [Token::QUESTION], [Token::COMMA],
        [Token::RVALUE, 'それ', Token::VAR_SORE], [Token::QUESTION],
        [Token::ARRAY_CLOSE],
      )
    end
  end
end
