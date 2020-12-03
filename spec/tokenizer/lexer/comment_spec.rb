require './src/token'
require './src/tokenizer/lexer'
require './spec/contexts/lexer'

include Tokenizer

RSpec.describe Lexer, 'comment' do
  include_context 'lexer'

  describe '#next_token' do
    it 'tokenizes comments' do
      mock_reader(
        "※これはコメントです\n"
      )

      expect(tokens).to be_empty
    end

    it 'tokenizes comments in full-width' do
      mock_reader(
        "※これもこめんとです\n"
      )

      expect(tokens).to be_empty
    end

    it 'allows comments after variable declarations' do
      mock_reader(
        "変数は 10※ほげ\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '変数', Token::VARIABLE], [Token::RVALUE, '10', Token::VAL_NUM],
      )
    end

    it 'allows comments after array declarations' do
      mock_reader(
        "はいれつは 1,2,3※ほげ\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'はいれつ', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::RVALUE, '1', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '2', Token::VAL_NUM], [Token::COMMA],
        [Token::RVALUE, '3', Token::VAL_NUM],
        [Token::ARRAY_CLOSE],
      )
    end

    it 'allows comments after function definitions' do
      mock_reader(
        "ほげるとは※関数定義\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'allows comments after function calls' do
      mock_reader(
        "ほげるとは\n" \
        "　・・・\n" \
        "ほげる ※関数呼び\n"
      )

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
        [Token::SCOPE_CLOSE],
        [Token::FUNCTION_CALL, 'ほげる', Token::FUNC_USER],
      )
    end

    it 'tokenizes block comments' do
      mock_reader(
        "(\n" \
        "　コメントですよ\n" \
        ")\n"
      )

      expect(tokens).to be_empty
    end

    it 'tokenizes block comments mid-line' do
      mock_reader(
        "ほげは( コメント ) 10\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE], [Token::RVALUE, '10', Token::VAL_NUM],
      )
    end

    it 'tokenizes code following block comments' do
      mock_reader(
        "( こういう書き方は気持ち悪い\n" \
        "と言っても、許します)ほげは 10\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE], [Token::RVALUE, '10', Token::VAL_NUM],
      )
    end

    it 'does not strip comments inside strings' do
      mock_reader(
        "ほげは 「※コメントじゃない」\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE], [Token::RVALUE, '「※コメントじゃない」', Token::VAL_STR],
      )
    end

    it 'does not strip block comments inside strings' do
      mock_reader(
        "ほげは 「(コメントじゃない)」\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE], [Token::RVALUE, '「(コメントじゃない)」', Token::VAL_STR]
      )
    end

    it 'strips block comments overlapping strings' do
      mock_reader(
        "ほげ(いきなり「コメント！)は 「コメントじゃない」\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE], [Token::RVALUE, '「コメントじゃない」', Token::VAL_STR],
      )
    end
  end
end
