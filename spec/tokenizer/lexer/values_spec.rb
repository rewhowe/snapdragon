require './src/tokenizer/lexer.rb'
require './src/tokenizer/token.rb'
require './spec/contexts/lexer.rb'

include Tokenizer

RSpec.describe Lexer, 'values' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'recognizes all types of values' do
      mock_reader(
        "整数は 10\n" \
        "浮動小数点数は -3.14\n" \
        "文字列は 「あいうえお」\n" \
        "ハイレツは 配列\n" \
        "ハイレツは 1、2、3\n" \
        "トルーは 真\n" \
        "トルーは 肯定\n" \
        "トルーは はい\n" \
        "フォルスは 偽\n" \
        "フォルスは 否定\n" \
        "フォルスは いいえ\n" \
        "グローバル変数は それ\n" \
        "もう一つのグローバル変数は あれ\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '整数'],                     [Token::VARIABLE, '10'],
        [Token::ASSIGNMENT, '浮動小数点数'],             [Token::VARIABLE, '-3.14'],
        [Token::ASSIGNMENT, '文字列'],                   [Token::VARIABLE, '「あいうえお」'],
        [Token::ASSIGNMENT, 'ハイレツ'],                 [Token::VARIABLE, '配列'],
        [Token::ASSIGNMENT, 'ハイレツ'],
        [Token::ARRAY_BEGIN],
        [Token::VARIABLE, '1'], [Token::COMMA],
        [Token::VARIABLE, '2'], [Token::COMMA],
        [Token::VARIABLE, '3'],
        [Token::ARRAY_CLOSE],
        [Token::ASSIGNMENT, 'トルー'],                   [Token::VARIABLE, '真'],
        [Token::ASSIGNMENT, 'トルー'],                   [Token::VARIABLE, '肯定'],
        [Token::ASSIGNMENT, 'トルー'],                   [Token::VARIABLE, 'はい'],
        [Token::ASSIGNMENT, 'フォルス'],                 [Token::VARIABLE, '偽'],
        [Token::ASSIGNMENT, 'フォルス'],                 [Token::VARIABLE, '否定'],
        [Token::ASSIGNMENT, 'フォルス'],                 [Token::VARIABLE, 'いいえ'],
        [Token::ASSIGNMENT, 'グローバル変数'],           [Token::VARIABLE, 'それ'],
        [Token::ASSIGNMENT, 'もう一つのグローバル変数'], [Token::VARIABLE, 'あれ'],
      )
    end

    it 'recognizes full-width numbers' do
      mock_reader(
        "数値は ー４６．４９\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '数値'], [Token::VARIABLE, '-46.49']
      )
    end

    it 'recognizes escaping 」 in strings' do
      mock_reader(
        "挨拶は 「「おっはー！\\」ということ」\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '挨拶'], [Token::VARIABLE, '「「おっはー！\」ということ」']
      )
    end

    it 'strips multiline string assignments' do
      mock_reader(
        "文章は 「人の世に      \n" \
        "         生まれし頃より\n" \
        "         戦道          \n" \
        "         桜花乱舞！」  \n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '文章'], [Token::VARIABLE, '「人の世に生まれし頃より戦道桜花乱舞！」']
      )
    end

    it 'strips multiline string parameters' do
      mock_reader(
        "「こんにち　ワン  \n" \
        "  ありがと　ウサギ\n" \
        "  こんばん　ワニ  \n" \
        "  さよな　ライオン」を 言う\n"
      )

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '「こんにち　ワンありがと　ウサギこんばん　ワニさよな　ライオン」'],
        [Token::FUNCTION_CALL, '言う'],
      )
    end
  end
end
