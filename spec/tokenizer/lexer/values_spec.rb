require './src/token'
require './src/tokenizer/built_ins'
require './src/tokenizer/lexer'
require './spec/contexts/lexer'

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

      expect(tokens).to contain_exactly_in_order(
        [Token::ASSIGNMENT, '整数', Token::VARIABLE],               [Token::RVALUE, '10', Token::VAL_NUM],
        [Token::ASSIGNMENT, '浮動小数点数', Token::VARIABLE],       [Token::RVALUE, '-3.14', Token::VAL_NUM],
        [Token::ASSIGNMENT, '文字列', Token::VARIABLE],             [Token::RVALUE, '「あいうえお」', Token::VAL_STR],
        [Token::ASSIGNMENT, 'ハイレツ', Token::VARIABLE],           [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::ASSIGNMENT, 'ハイレツ', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::RVALUE, '1', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '2', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '3', Token::VAL_NUM],
        [Token::ARRAY_CLOSE],
        [Token::ASSIGNMENT, 'トルー', Token::VARIABLE],             [Token::RVALUE, '真', Token::VAL_TRUE],
        [Token::ASSIGNMENT, 'トルー', Token::VARIABLE],             [Token::RVALUE, '肯定', Token::VAL_TRUE],
        [Token::ASSIGNMENT, 'トルー', Token::VARIABLE],             [Token::RVALUE, 'はい', Token::VAL_TRUE],
        [Token::ASSIGNMENT, 'フォルス', Token::VARIABLE],           [Token::RVALUE, '偽', Token::VAL_FALSE],
        [Token::ASSIGNMENT, 'フォルス', Token::VARIABLE],           [Token::RVALUE, '否定', Token::VAL_FALSE],
        [Token::ASSIGNMENT, 'フォルス', Token::VARIABLE],           [Token::RVALUE, 'いいえ', Token::VAL_FALSE],
        [Token::ASSIGNMENT, 'null', Token::VARIABLE],           [Token::RVALUE, '無', Token::VAL_NULL],
        [Token::ASSIGNMENT, 'null', Token::VARIABLE],           [Token::RVALUE, '無い', Token::VAL_NULL],
        [Token::ASSIGNMENT, 'null', Token::VARIABLE],           [Token::RVALUE, '無し', Token::VAL_NULL],
        [Token::ASSIGNMENT, 'null', Token::VARIABLE],           [Token::RVALUE, 'ヌル', Token::VAL_NULL],
        [Token::ASSIGNMENT, 'グローバル変数', Token::VARIABLE],     [Token::RVALUE, 'それ', Token::VAR_SORE],
        [Token::ASSIGNMENT, 'もう一つのグローバル変数', Token::VARIABLE], [Token::RVALUE, 'あれ', Token::VAR_ARE],
      )
    end

    it 'recognizes full-width numbers' do
      mock_reader(
        "数値は ー４６．４９\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::ASSIGNMENT, '数値', Token::VARIABLE], [Token::RVALUE, '-46.49', Token::VAL_NUM]
      )
    end

    it 'recognizes escaping 」 in strings' do
      mock_reader(
        "挨拶は 「「おっはー！\\」ということ」\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::ASSIGNMENT, '挨拶', Token::VARIABLE],
        [Token::RVALUE, '「「おっはー！\\」ということ」', Token::VAL_STR]
      )
    end

    it 'recognizes various forms of escaping across multiline strings' do
      mock_reader(
        "挨拶は 「「おっはー！\\」\n" \
        "         ということ\n\\\\n」\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::ASSIGNMENT, '挨拶', Token::VARIABLE],
        [Token::RVALUE, '「「おっはー！\\」ということ\\\\n」', Token::VAL_STR]
      )
    end

    it 'recognizes triply-escaping 」 in strings (and 5, 7, etc...)' do
      mock_reader(
        "挨拶は 「「おっはー！\\」\n" \
        "         ということ\n\\\\n」\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::ASSIGNMENT, '挨拶', Token::VARIABLE],
        [Token::RVALUE, '「「おっはー！\\」ということ\\\\n」', Token::VAL_STR]
      )
    end

    it 'strips multiline string assignments' do
      mock_reader(
        "文章は 「人の世に      \n" \
        "         生まれし頃より\n" \
        "         戦道          \n" \
        "         桜花乱舞！」  \n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::ASSIGNMENT, '文章', Token::VARIABLE],
        [Token::RVALUE, '「人の世に生まれし頃より戦道桜花乱舞！」', Token::VAL_STR]
      )
    end

    it 'strips multiline string parameters' do
      mock_reader(
        "「こんにち　ワン  \n" \
        "  ありがと　ウサギ\n" \
        "  こんばん　ワニ  \n" \
        "  さよな　ライオン」を 言う\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::PARAMETER, '「こんにち　ワンありがと　ウサギこんばん　ワニさよな　ライオン」', Token::VAL_STR],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::PRINT, Token::FUNC_BUILT_IN],
      )
    end
  end
end
