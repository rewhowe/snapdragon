require './src/tokenizer/lexer.rb'
require './src/tokenizer/token.rb'
require './spec/contexts/lexer.rb'

include Tokenizer

RSpec.describe Lexer, 'comment' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'tokenizes comments' do
      write_test_file [
        '(これはコメントです'
      ]

      expect(tokens).to be_empty
    end

    it 'tokenizes comments in full-width' do
      write_test_file [
        '（これもこめんとです'
      ]

      expect(tokens).to be_empty
    end

    it 'allows comments after variable declarations' do
      write_test_file [
        '変数は 10（ほげ'
      ]

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '変数'], [Token::VARIABLE, '10']
      )
    end

    it 'allows comments after array declarations' do
      write_test_file [
        'はいれつは 1,2,3（ほげ'
      ]

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'はいれつ'],
        [Token::ARRAY_BEGIN],
        [Token::VARIABLE, '1'], [Token::COMMA],
        [Token::VARIABLE, '2'], [Token::COMMA],
        [Token::VARIABLE, '3'],
        [Token::ARRAY_CLOSE],
      )
    end

    it 'allows comments after function definitions' do
      write_test_file [
        'ほげるとは（関数定義',
        '　・・・',
      ]

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'allows comments after function calls' do
      write_test_file [
        'ほげるとは',
        '　・・・',
        'ほげる (関数呼び',
      ]

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
        [Token::FUNCTION_CALL, 'ほげる'],
      )
    end

    it 'tokenizes block comments' do
      write_test_file [
        '※',
        '　コメントですよ',
        '※',
      ]

      expect(tokens).to be_empty
    end

    it 'tokenizes block comments mid-line' do
      write_test_file [
        'ほげは※ コメント ※ 10'
      ]

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ'], [Token::VARIABLE, '10']
      )
    end

    it 'tokenizes code following block comments' do
      write_test_file [
        '※ こういう書き方は気持ち悪い',
        'と言っても、許します※ほげは 10'
      ]

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ'], [Token::VARIABLE, '10']
      )
    end

    it 'does not strip comments inside strings' do
      write_test_file [
        'ほげは 「(コメントじゃない」',
      ]

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ'], [Token::VARIABLE, '「(コメントじゃない」']
      )
    end

    it 'does not strip block comments inside strings' do
      write_test_file [
        'ほげは 「※コメントじゃない※」',
      ]

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ'], [Token::VARIABLE, '「※コメントじゃない※」']
      )
    end

    it 'strips block comments overlapping strings' do
      write_test_file [
        'ほげ※いきなり「コメント！※は 「コメントじゃない」',
      ]

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ'], [Token::VARIABLE, '「コメントじゃない」']
      )
    end
  end
end
