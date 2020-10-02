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
        "nullは 無\n" \
        "nullは 無い\n" \
        "nullは 無し\n" \
        "nullは ヌル\n" \
        "グローバル変数は それ\n" \
        "もう一つのグローバル変数は あれ\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '整数', Token::VARIABLE],               [Token::VARIABLE, '10', Token::VAR_NUM],
        [Token::ASSIGNMENT, '浮動小数点数', Token::VARIABLE],       [Token::VARIABLE, '-3.14', Token::VAR_NUM],
        [Token::ASSIGNMENT, '文字列', Token::VARIABLE],             [Token::VARIABLE, '「あいうえお」', Token::VAR_STR],
        [Token::ASSIGNMENT, 'ハイレツ', Token::VARIABLE],           [Token::VARIABLE, '配列', Token::VAR_ARRAY],
        [Token::ASSIGNMENT, 'ハイレツ', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::VARIABLE, '1', Token::VAR_NUM], [Token::COMMA],
        [Token::VARIABLE, '2', Token::VAR_NUM], [Token::COMMA],
        [Token::VARIABLE, '3', Token::VAR_NUM],
        [Token::ARRAY_CLOSE],
        [Token::ASSIGNMENT, 'トルー', Token::VARIABLE],             [Token::VARIABLE, '真', Token::VAR_BOOL],
        [Token::ASSIGNMENT, 'トルー', Token::VARIABLE],             [Token::VARIABLE, '肯定', Token::VAR_BOOL],
        [Token::ASSIGNMENT, 'トルー', Token::VARIABLE],             [Token::VARIABLE, 'はい', Token::VAR_BOOL],
        [Token::ASSIGNMENT, 'フォルス', Token::VARIABLE],           [Token::VARIABLE, '偽', Token::VAR_BOOL],
        [Token::ASSIGNMENT, 'フォルス', Token::VARIABLE],           [Token::VARIABLE, '否定', Token::VAR_BOOL],
        [Token::ASSIGNMENT, 'フォルス', Token::VARIABLE],           [Token::VARIABLE, 'いいえ', Token::VAR_BOOL],
        [Token::ASSIGNMENT, 'null', Token::VARIABLE],           [Token::VARIABLE, '無', Token::VAR_NULL],
        [Token::ASSIGNMENT, 'null', Token::VARIABLE],           [Token::VARIABLE, '無い', Token::VAR_NULL],
        [Token::ASSIGNMENT, 'null', Token::VARIABLE],           [Token::VARIABLE, '無し', Token::VAR_NULL],
        [Token::ASSIGNMENT, 'null', Token::VARIABLE],           [Token::VARIABLE, 'ヌル', Token::VAR_NULL],
        [Token::ASSIGNMENT, 'グローバル変数', Token::VARIABLE],     [Token::VARIABLE, 'それ', Token::VAR_SORE],
        [Token::ASSIGNMENT, 'もう一つのグローバル変数', Token::VARIABLE], [Token::VARIABLE, 'あれ', Token::VAR_ARE],
      )
    end

    it 'recognizes full-width numbers' do
      mock_reader(
        "数値は ー４６．４９\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '数値', Token::VARIABLE], [Token::VARIABLE, '-46.49', Token::VAR_NUM]
      )
    end

    it 'recognizes escaping 」 in strings' do
      mock_reader(
        "挨拶は 「「おっはー！\\」ということ」\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '挨拶', Token::VARIABLE],
        [Token::VARIABLE, '「「おっはー！\」ということ」', Token::VAR_STR]
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
        [Token::ASSIGNMENT, '文章', Token::VARIABLE],
        [Token::VARIABLE, '「人の世に生まれし頃より戦道桜花乱舞！」', Token::VAR_STR]
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
        [Token::PARAMETER, '「こんにち　ワンありがと　ウサギこんばん　ワニさよな　ライオン」', Token::VAR_STR],
        [Token::FUNCTION_CALL, '言う'],
      )
    end
  end
end
