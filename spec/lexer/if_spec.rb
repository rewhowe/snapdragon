require './src/lexer.rb'
require './src/token.rb'
require './spec/contexts/lexer.rb'

RSpec.describe Lexer, 'values' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'tokenizes if === statement' do
      write_test_file [
        'もし 1が 1と 等しければ',
        '　・・・'
      ]

      expect(tokens).to contain_exactly(
        [Token::IF, nil],
        [Token::COMP_EQ, nil],
        [Token::VARIABLE, '1'],
        [Token::VARIABLE, '1'],
        [Token::SCOPE_BEGIN, nil],
        [Token::NO_OP, nil],
        [Token::SCOPE_CLOSE, nil],
      )
    end

    it 'tokenizes if === statement without kanji' do
      write_test_file [
        'もし 1が 1と ひとしければ',
      ]

      expect(tokens).to contain_exactly(
        [Token::IF, nil],
        [Token::COMP_EQ, nil],
        [Token::VARIABLE, '1'],
        [Token::VARIABLE, '1'],
        [Token::SCOPE_BEGIN, nil],
        [Token::SCOPE_CLOSE, nil],
      )
    end

    it 'tokenizes if !== statement' do
      %w[
        等しくなければ
        ひとしくなければ
      ].each do |comparator|
        write_test_file [
          "もし 1が 1と #{comparator}",
        ]

        expect(tokens).to contain_exactly(
          [Token::IF, nil],
          [Token::COMP_NEQ, nil],
          [Token::VARIABLE, '1'],
          [Token::VARIABLE, '1'],
          [Token::SCOPE_BEGIN, nil],
          [Token::SCOPE_CLOSE, nil],
        )
      end
    end

    it 'tokenizes if < statement' do
      %w[
        小さければ
        ちいさければ
        短ければ
        みじかければ
        低ければ
        ひくければ
        少なければ
        すくなければ
      ].each do |comparator|
        write_test_file [
          "もし 1が 1より #{comparator}",
        ]

        expect(tokens).to contain_exactly(
          [Token::IF, nil],
          [Token::COMP_LT, nil],
          [Token::VARIABLE, '1'],
          [Token::VARIABLE, '1'],
          [Token::SCOPE_BEGIN, nil],
          [Token::SCOPE_CLOSE, nil],
        )
      end
    end

    it 'tokenizes if <= statement' do
      write_test_file [
        'もし 1が 1以下 ならば',
      ]

      expect(tokens).to contain_exactly(
        [Token::IF, nil],
        [Token::COMP_LTEQ, nil],
        [Token::VARIABLE, '1'],
        [Token::VARIABLE, '1'],
        [Token::SCOPE_BEGIN, nil],
        [Token::SCOPE_CLOSE, nil],
      )
    end

    it 'tokenizes if >= statement' do
      write_test_file [
        'もし 1が 1以上 ならば',
      ]

      expect(tokens).to contain_exactly(
        [Token::IF, nil],
        [Token::COMP_GTEQ, nil],
        [Token::VARIABLE, '1'],
        [Token::VARIABLE, '1'],
        [Token::SCOPE_BEGIN, nil],
        [Token::SCOPE_CLOSE, nil],
      )
    end

    it 'tokenizes if > statement' do
      %w[
        大きければ
        おおきければ
        長ければ
        ながければ
        高ければ
        たかければ
        多ければ
        おおければ
      ].each do |comparator|
        write_test_file [
          "もし 1が 1より #{comparator}",
        ]

        expect(tokens).to contain_exactly(
          [Token::IF, nil],
          [Token::COMP_GT, nil],
          [Token::VARIABLE, '1'],
          [Token::VARIABLE, '1'],
          [Token::SCOPE_BEGIN, nil],
          [Token::SCOPE_CLOSE, nil],
        )
      end
    end

    it 'tokenizes if statements with variables' do
      write_test_file [
        'ほげは 1',
        'ふがは 2',
        'もし ほげが ふがと 等しければ',
      ]

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ'],
        [Token::VARIABLE, '1'],
        [Token::ASSIGNMENT, 'ふが'],
        [Token::VARIABLE, '2'],
        [Token::IF, nil],
        [Token::COMP_EQ, nil],
        [Token::VARIABLE, 'ほげ'],
        [Token::VARIABLE, 'ふが'],
        [Token::SCOPE_BEGIN, nil],
        [Token::SCOPE_CLOSE, nil],
      )
    end

    it 'tokenizes if variable? statement' do
      write_test_file [
        'ほげは 正',
        'もし ほげ？ ならば',
      ]

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ'],
        [Token::VARIABLE, '正'],
        [Token::IF, nil],
        [Token::VARIABLE, 'ほげ'],
        [Token::SCOPE_BEGIN, nil],
        [Token::SCOPE_CLOSE, nil],
      )
    end

    it 'tokenizes if value? statement' do
      write_test_file [
        'もし 「文字列もおｋ？」？ ならば',
      ]

      expect(tokens).to contain_exactly(
        [Token::IF, nil],
        [Token::VARIABLE, '「文字列もおｋ？」'],
        [Token::SCOPE_BEGIN, nil],
        [Token::SCOPE_CLOSE, nil],
      )
    end

    it 'tokenizes if function call? statement' do
      write_test_file [
        'もし 0に 1を 足して？ ならば'
      ]

      expect(tokens).to contain_exactly(
        [Token::IF, nil],
        [Token::PARAMETER, '0'],
        [Token::PARAMETER, '1'],
        [Token::FUNCTION_CALL, '足す'],
        [Token::SCOPE_BEGIN, nil],
        [Token::SCOPE_CLOSE, nil],
      )
    end

    it 'closes if statement scope when next-line token unrelated' do
      write_test_file [
        'もし 1が 1と 等しければ',
        'ほげは 1',
      ]

      expect(tokens).to contain_exactly(
        [Token::IF, nil],
        [Token::COMP_EQ, nil],
        [Token::VARIABLE, '1'],
        [Token::VARIABLE, '1'],
        [Token::SCOPE_BEGIN, nil],
        [Token::SCOPE_CLOSE, nil],
        [Token::ASSIGNMENT, 'ほげ'],
        [Token::VARIABLE, '1'],
      )
    end

    # it 'tokenizes else if statement' do
    #   # TODO: test
    #   fail
    # end

    # it 'tokenizes else statements' do
    #   # TODO: test
    #   fail
    # end
  end
end
