require './src/tokenizer/lexer.rb'
require './src/tokenizer/token.rb'
require './spec/contexts/lexer.rb'

include Tokenizer

RSpec.describe Lexer, 'values' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'tokenizes if === statement' do
      write_test_file [
        'もし 1が 1と 等しければ',
        '　・・・'
      ]

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_EQ],
        [Token::VARIABLE, '1'],
        [Token::VARIABLE, '1'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes if === statement without kanji' do
      write_test_file [
        'もし 1が 1と ひとしければ',
      ]

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_EQ],
        [Token::VARIABLE, '1'],
        [Token::VARIABLE, '1'],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
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
          [Token::IF],
          [Token::COMP_NEQ],
          [Token::VARIABLE, '1'],
          [Token::VARIABLE, '1'],
          [Token::SCOPE_BEGIN],
          [Token::SCOPE_CLOSE],
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
          [Token::IF],
          [Token::COMP_LT],
          [Token::VARIABLE, '1'],
          [Token::VARIABLE, '1'],
          [Token::SCOPE_BEGIN],
          [Token::SCOPE_CLOSE],
        )
      end
    end

    it 'tokenizes if <= statement' do
      write_test_file [
        'もし 1が 1以下 ならば',
      ]

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_LTEQ],
        [Token::VARIABLE, '1'],
        [Token::VARIABLE, '1'],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes if >= statement' do
      write_test_file [
        'もし 1が 1以上 ならば',
      ]

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_GTEQ],
        [Token::VARIABLE, '1'],
        [Token::VARIABLE, '1'],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
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
          [Token::IF],
          [Token::COMP_GT],
          [Token::VARIABLE, '1'],
          [Token::VARIABLE, '1'],
          [Token::SCOPE_BEGIN],
          [Token::SCOPE_CLOSE],
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
        [Token::IF],
        [Token::COMP_EQ],
        [Token::VARIABLE, 'ほげ'],
        [Token::VARIABLE, 'ふが'],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
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
        [Token::IF],
        [Token::VARIABLE, 'ほげ'],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes if value? statement' do
      write_test_file [
        'もし 「文字列もおｋ？」？ ならば',
      ]

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::VARIABLE, '「文字列もおｋ？」'],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes if function call? statement' do
      write_test_file [
        'もし 0に 1を 足して？ ならば'
      ]

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::PARAMETER, '0'],
        [Token::PARAMETER, '1'],
        [Token::FUNCTION_CALL, '足す'],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'closes if statement scope when next-line token unrelated' do
      write_test_file [
        'もし 1が 1と 等しければ',
        'ほげは 1',
      ]

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_EQ],
        [Token::VARIABLE, '1'],
        [Token::VARIABLE, '1'],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
        [Token::ASSIGNMENT, 'ほげ'],
        [Token::VARIABLE, '1'],
      )
    end

    it 'tokenizes else if statement' do
      write_test_file [
        'もし 1が 0？ ならば',
        'もしくは 1が 1？ ならば',
      ]

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_EQ],
        [Token::VARIABLE, '1'],
        [Token::VARIABLE, '0'],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
        [Token::ELSE_IF],
        [Token::COMP_EQ],
        [Token::VARIABLE, '1'],
        [Token::VARIABLE, '1'],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes else statements' do
      write_test_file [
        'もし 1が 0？ ならば',
        'それ以外',
      ]

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_EQ],
        [Token::VARIABLE, '1'],
        [Token::VARIABLE, '0'],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
        [Token::ELSE],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes else if + else statements' do
      write_test_file [
        'もし 1が 0？ ならば',
        'もしくは 1が 1？ ならば',
        'それ以外',
      ]

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_EQ],
        [Token::VARIABLE, '1'],
        [Token::VARIABLE, '0'],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
        [Token::ELSE_IF],
        [Token::COMP_EQ],
        [Token::VARIABLE, '1'],
        [Token::VARIABLE, '1'],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
        [Token::ELSE],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end
  end
end
