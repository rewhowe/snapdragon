require './src/lexer.rb'
require './src/token.rb'
require './spec/contexts/lexer.rb'

RSpec.describe Lexer, 'values' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'recognizes all types of values' do
      write_test_file [
        '整数は 10',
        '浮動小数点数は -3.14',
        '文字列は 「あいうえお」',
        'ハイレツは 配列',
        'ハイレツは 1、2、3',
        'トルーは 真',
        'トルーは 肯定',
        'トルーは はい',
        'フォルスは 偽',
        'フォルスは 否定',
        'フォルスは いいえ',
        'グローバル変数は それ',
        'もう一つのグローバル変数は あれ',
      ]

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '整数'],                     [Token::VARIABLE, '10'],
        [Token::ASSIGNMENT, '浮動小数点数'],             [Token::VARIABLE, '-3.14'],
        [Token::ASSIGNMENT, '文字列'],                   [Token::VARIABLE, '「あいうえお」'],
        [Token::ASSIGNMENT, 'ハイレツ'],                 [Token::VARIABLE, '配列'],
        [Token::ASSIGNMENT, 'ハイレツ'],
        [Token::ARRAY_BEGIN, nil],
        [Token::VARIABLE, '1'], [Token::COMMA, nil],
        [Token::VARIABLE, '2'], [Token::COMMA, nil],
        [Token::VARIABLE, '3'],
        [Token::ARRAY_CLOSE, nil],
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
      write_test_file [
        '挨拶は 「「おっはー！\」ということ」'
      ]

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '挨拶'], [Token::VARIABLE, '「「おっはー！\」ということ」']
      )
    end
  end
end
