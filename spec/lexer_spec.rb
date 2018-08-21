require './src/lexer.rb'
require './src/token.rb'

RSpec.describe Lexer do
  def write_contents(contents)
    @test_file.open.truncate 0
    @test_file.write contents.join "\n"
    @test_file.close
  end

  before :all do
    @test_file = Tempfile.new('testfile')
  end

  after :all do
    @test_file.delete
  end

  describe '#tokenize' do
    it 'tokenizes variable declarations' do
      write_contents [
        'ほげは 10',
      ]

      tokens = Lexer.tokenize(@test_file.path).map { |token| [ token.type, token.content ] }

      expect(tokens).to contain_exactly(
        [ Token::ASSIGNMENT, 'ほげ' ],
        [ Token::VARIABLE, '10' ],
      )
    end

    it 'recognizes all types of values' do
      write_contents [
        '整数は 10',
        '浮動小数点数は -3.14',
        '文字列は 「あいうえお」',
        'ハイレツは 配列',
        'トルーは 真',
        'トルーは 肯定',
        'トルーは はい',
        'フォルスは 偽',
        'フォルスは 否定',
        'フォルスは いいえ',
        'グローバル変数は それ',
        'もう一つのグローバル変数は あれ',
      ]

      tokens = Lexer.tokenize(@test_file.path).map { |token| [ token.type, token.content ] }

      expect(tokens).to contain_exactly(
        [ Token::ASSIGNMENT, '整数' ],                     [ Token::VARIABLE, '10' ],
        [ Token::ASSIGNMENT, '浮動小数点数' ],             [ Token::VARIABLE, '-3.14' ],
        [ Token::ASSIGNMENT, '文字列' ],                   [ Token::VARIABLE, '「あいうえお」' ],
        [ Token::ASSIGNMENT, 'ハイレツ' ],                 [ Token::VARIABLE, '配列' ],
        [ Token::ASSIGNMENT, 'トルー' ],                   [ Token::VARIABLE, '真' ],
        [ Token::ASSIGNMENT, 'トルー' ],                   [ Token::VARIABLE, '肯定' ],
        [ Token::ASSIGNMENT, 'トルー' ],                   [ Token::VARIABLE, 'はい' ],
        [ Token::ASSIGNMENT, 'フォルス' ],                 [ Token::VARIABLE, '偽' ],
        [ Token::ASSIGNMENT, 'フォルス' ],                 [ Token::VARIABLE, '否定' ],
        [ Token::ASSIGNMENT, 'フォルス' ],                 [ Token::VARIABLE, 'いいえ' ],
        [ Token::ASSIGNMENT, 'グローバル変数' ],           [ Token::VARIABLE, 'それ' ],
        [ Token::ASSIGNMENT, 'もう一つのグローバル変数' ], [ Token::VARIABLE, 'あれ' ],
      )
    end
  end

  describe 'error handling' do
    it 'raises an error when missing tokens' do
      write_contents [
        '変数は',
      ]

      expect { Lexer.tokenize(@test_file.path) } .to raise_error StandardError
    end
  end
end
