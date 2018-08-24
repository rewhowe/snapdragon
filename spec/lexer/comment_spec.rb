require './src/lexer.rb'
require './src/token.rb'
require './spec/contexts/lexer.rb'

RSpec.describe Lexer, 'comment' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'tokenizes comments' do
      write_test_file [
        '(これはコメントです'
      ]

      expect(tokens).to contain_exactly(
        [Token::INLINE_COMMENT, 'これはコメントです'],
      )
    end

    it 'tokenizes comments in full-width' do
      write_test_file [
        '（これもこめんとです'
      ]

      expect(tokens).to contain_exactly(
        [Token::INLINE_COMMENT, 'これもこめんとです'],
      )
    end

    it 'allows comments after variable declarations' do
      write_test_file [
        '変数は 10（ほげ'
      ]

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '変数'], [Token::VARIABLE, '10'], [Token::INLINE_COMMENT, 'ほげ']
      )
    end

    it 'allows comments after array declarations' do
      write_test_file [
        'はいれつは 1,2,3（ほげ'
      ]

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'はいれつ'],
        [Token::ARRAY_BEGIN, nil],
        [Token::VARIABLE, '1'], [Token::COMMA, nil],
        [Token::VARIABLE, '2'], [Token::COMMA, nil],
        [Token::VARIABLE, '3'],
        [Token::ARRAY_CLOSE, nil],
        [Token::INLINE_COMMENT, 'ほげ'],
      )
    end

    it 'allows comments after function definitions' do
      write_test_file [
        'ほげるとは（関数定義',
        '　・・・',
      ]

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN, nil],
        [Token::INLINE_COMMENT, '関数定義'],
        [Token::NO_OP, nil],
        [Token::SCOPE_CLOSE, nil],
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
        [Token::SCOPE_BEGIN, nil],
        [Token::NO_OP, nil],
        [Token::SCOPE_CLOSE, nil],
        [Token::FUNCTION_CALL, 'ほげる'],
        [Token::INLINE_COMMENT, '関数呼び'],
      )
    end

    it 'tokenizes block comments' do
      write_test_file [
        '※',
        '　コメントですよ',
        '※',
      ]

      expect(tokens).to contain_exactly(
        [Token::BLOCK_COMMENT, ''],
        [Token::COMMENT, 'コメントですよ'],
        [Token::BLOCK_COMMENT, ''],
      )
    end
  end
end
