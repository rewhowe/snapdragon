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

    it 'recognizes escaping 」 in strings' do
      mock_reader(
        "挨拶は 「「おっはー！\\」ということ」\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '挨拶'], [Token::VARIABLE, '「「おっはー！\」ということ」']
      )
    end
  end
end
