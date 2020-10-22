require './src/token'
require './src/tokenizer/lexer'
require './spec/contexts/lexer'

include Tokenizer

RSpec.describe Lexer, 'values' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'tokenizes if == statement' do
      mock_reader(
        "もし 1が 1と 等しければ\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_EQ],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes if == statement without kanji' do
      mock_reader(
        "もし 1が 1と ひとしければ\n",
      )

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_EQ],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes if == value? statement' do
      mock_reader(
        "もし 1が 1？ ならば\n",
      )

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_EQ],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes not-if == value? statement' do
      mock_reader(
        "もし 1が 1？ でなければ\n",
      )

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_NEQ],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes if != statement' do
      %w[
        等しくなければ
        ひとしくなければ
      ].each do |comparator|
        mock_reader(
          "もし 1が 1と #{comparator}\n"
        )

        expect(tokens).to contain_exactly(
          [Token::IF],
          [Token::COMP_NEQ],
          [Token::RVALUE, '1', Token::VAL_NUM],
          [Token::RVALUE, '1', Token::VAL_NUM],
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
        mock_reader(
          "もし 1が 1より #{comparator}\n"
        )

        expect(tokens).to contain_exactly(
          [Token::IF],
          [Token::COMP_LT],
          [Token::RVALUE, '1', Token::VAL_NUM],
          [Token::RVALUE, '1', Token::VAL_NUM],
          [Token::SCOPE_BEGIN],
          [Token::SCOPE_CLOSE],
        )
      end
    end

    it 'tokenizes if <= statement' do
      mock_reader(
        "もし 1が 1以下 ならば\n"
      )

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_LTEQ],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes if >= statement' do
      mock_reader(
        "もし 1が 1以上 ならば\n"
      )

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_GTEQ],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::RVALUE, '1', Token::VAL_NUM],
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
        mock_reader(
          "もし 1が 1より #{comparator}\n"
        )

        expect(tokens).to contain_exactly(
          [Token::IF],
          [Token::COMP_GT],
          [Token::RVALUE, '1', Token::VAL_NUM],
          [Token::RVALUE, '1', Token::VAL_NUM],
          [Token::SCOPE_BEGIN],
          [Token::SCOPE_CLOSE],
        )
      end
    end

    it 'tokenizes if statements with variables' do
      mock_reader(
        "ほげは 1\n" \
        "ふがは 2\n" \
        "もし ほげが ふがと 等しければ\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::ASSIGNMENT, 'ふが', Token::VARIABLE],
        [Token::RVALUE, '2', Token::VAL_NUM],
        [Token::IF],
        [Token::COMP_EQ],
        [Token::RVALUE, 'ほげ', Token::VARIABLE],
        [Token::RVALUE, 'ふが', Token::VARIABLE],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes if variable? statement' do
      mock_reader(
        "ほげは 正\n" \
        "もし ほげ？ ならば\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE],
        [Token::RVALUE, '正', Token::VAL_TRUE],
        [Token::IF],
        [Token::COMP_EQ],
        [Token::RVALUE, '真', Token::VAL_TRUE],
        [Token::RVALUE, 'ほげ', Token::VARIABLE],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes not-if variable? statement' do
      mock_reader(
        "ほげは 正\n" \
        "もし ほげ？ でなければ\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE],
        [Token::RVALUE, '正', Token::VAL_TRUE],
        [Token::IF],
        [Token::COMP_NEQ],
        [Token::RVALUE, '真', Token::VAL_TRUE],
        [Token::RVALUE, 'ほげ', Token::VARIABLE],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes if value? statement' do
      mock_reader(
        "もし 「文字列もおｋ？」？ ならば\n"
      )

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_EQ],
        [Token::RVALUE, '真', Token::VAL_TRUE],
        [Token::RVALUE, '「文字列もおｋ？」', Token::VAL_STR],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes not-if value? statement' do
      mock_reader(
        "もし 「文字列もおｋ？」？ でなければ\n"
      )

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_NEQ],
        [Token::RVALUE, '真', Token::VAL_TRUE],
        [Token::RVALUE, '「文字列もおｋ？」', Token::VAL_STR],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes if function call? statement' do
      mock_reader(
        "もし 0に 1を 足して？ ならば\n"
      )

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_EQ],
        [Token::RVALUE, '真', Token::VAL_TRUE],
        [Token::PARAMETER, '0', Token::VAL_NUM],
        [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, '足す', Token::FUNC_BUILT_IN],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes not-if function call? statement' do
      mock_reader(
        "もし 0に 1を 足した？ でなければ\n"
      )

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_NEQ],
        [Token::RVALUE, '真', Token::VAL_TRUE],
        [Token::PARAMETER, '0', Token::VAL_NUM],
        [Token::PARAMETER, '1', Token::VAL_NUM],
        [Token::FUNCTION_CALL, '足す', Token::FUNC_BUILT_IN],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes if function call? statement without parameters' do
      mock_reader(
        "ほげるとは\n" \
        "　・・・\n" \
        "もし ほげる？ ならば\n"
      )

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
        [Token::SCOPE_CLOSE],
        [Token::IF],
        [Token::COMP_EQ],
        [Token::RVALUE, '真', Token::VAL_TRUE],
        [Token::FUNCTION_CALL, 'ほげる', Token::FUNC_USER],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'closes if statement scope when next-line token unrelated' do
      mock_reader(
        "もし 1が 1と 等しければ\n" \
        "ほげは 1\n"
      )

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_EQ],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE],
        [Token::RVALUE, '1', Token::VAL_NUM],
      )
    end

    it 'tokenizes else if statement' do
      %w[
        もしくは
        または
      ].each do |else_if_keyword|
        mock_reader(
          "もし 1が 0？ ならば\n" \
          "#{else_if_keyword} 1が 1？ ならば\n"
        )

        expect(tokens).to contain_exactly(
          [Token::IF],
          [Token::COMP_EQ],
          [Token::RVALUE, '1', Token::VAL_NUM],
          [Token::RVALUE, '0', Token::VAL_NUM],
          [Token::SCOPE_BEGIN],
          [Token::SCOPE_CLOSE],
          [Token::ELSE_IF],
          [Token::COMP_EQ],
          [Token::RVALUE, '1', Token::VAL_NUM],
          [Token::RVALUE, '1', Token::VAL_NUM],
          [Token::SCOPE_BEGIN],
          [Token::SCOPE_CLOSE],
        )
      end
    end

    it 'tokenizes else statements' do
      %w[
        それ以外
        違えば
        ちがえば
      ].each do |else_keyword|
        mock_reader(
          "もし 1が 0？ ならば\n" \
          "#{else_keyword}\n"
        )

        expect(tokens).to contain_exactly(
          [Token::IF],
          [Token::COMP_EQ],
          [Token::RVALUE, '1', Token::VAL_NUM],
          [Token::RVALUE, '0', Token::VAL_NUM],
          [Token::SCOPE_BEGIN],
          [Token::SCOPE_CLOSE],
          [Token::ELSE],
          [Token::SCOPE_BEGIN],
          [Token::SCOPE_CLOSE],
        )
      end
    end

    it 'tokenizes else if + else statements' do
      mock_reader(
        "もし 1が 0？ ならば\n" \
        "もしくは 1が 1？ ならば\n" \
        "それ以外\n"
      )

      expect(tokens).to contain_exactly(
        [Token::IF],
        [Token::COMP_EQ],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::RVALUE, '0', Token::VAL_NUM],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
        [Token::ELSE_IF],
        [Token::COMP_EQ],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
        [Token::ELSE],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end
  end
end
