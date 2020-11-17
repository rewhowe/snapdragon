require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error on an unfinished assignment' do
      mock_reader(
        "変数は\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error on an unfinished list (followed by newline)' do
      mock_reader(
        "変数は 1、\n\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error for unclosed if statements' do
      mock_reader(
        "もし 「ほげ」と 言う？\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error for comments in if statements' do
      mock_reader(
        "もし 「ほげ」と 言う（コメント\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error on a comma inside an if statement' do
      mock_reader(
        "もし 1が 2？、2？ ならば\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error for trailing characters after bang' do
      mock_reader(
        "ほげるとは\n" \
        "　・・・\n" \
        "ほげる！ あと何かをする\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error on trailing characters after funtion def' do
      mock_reader(
        "ほげるとは 何かな？\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error when function def contains array' do
      mock_reader(
        "ほげ、ふが、ぴよを ほげる\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error when function def contains a property' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さを ほげるとは\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error when declaring function inside if statement' do
      mock_reader(
        "もし 引数を ほげるとは\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error on an if statement into function def ' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さを ほげるとは\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error when missing parameters in function call' do
      mock_reader(
        "タベモノを 食べるとは\n" \
        "　・・・\n" \
        "食べる\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error when wrong parameters in function call' do
      mock_reader(
        "タベモノを 食べるとは\n" \
        "　・・・\n" \
        "1で 食べる\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error when calling function nonexistent in scope' do
      mock_reader(
        "ほげるとは\n" \
        "　ふがるとは\n" \
        "　　・・・\n" \
        "ふがる\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error when calling function with wrong particles' do
      mock_reader(
        "タベモノを 食べるとは\n" \
        "　・・・\n" \
        "「ポテト」に 食べる\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error when function call contains array primitive' do
      mock_reader(
        "1、2、3に 4を 追加する\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error for a return with multiple parameters' do
      mock_reader(
        "1と 2を 返す\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error for incomplete loop iterators' do
      mock_reader(
        "「あいうえお」に 対して\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error for missing loop iterator parameter' do
      mock_reader(
        "対して 繰り返す\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error for multiple loop iterator parameters' do
      mock_reader(
        "あれは 配列\n" \
        "1に 「ほげ」に 対して 繰り返す\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error for an unexpected loop parameter' do
      mock_reader(
        "「永遠」に 繰り返す\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error for a loop inside an if condition' do
      mock_reader(
        "もし 「あいうえお」に 対して 繰り返す\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error on an assignment into loop' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さから あれの 長さまで 繰り返す\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error on an if statement into loop' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さに 対して 繰り返す\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error when property owner does not exist' do
      mock_reader(
        "ほげは ふがの 長さ\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error when property owner is not a variable or string' do
      mock_reader(
        "ほげは 1の 長さ\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error when property is invalid' do
      mock_reader(
        "あれは 配列\n" \
        "ほげは あれの ふが\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error on an assignment into if statement' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さ？ ならば\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error on an assignment into return' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さを 返す\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error on an assignment into function def' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さを ほげるとは\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error on an assignment into function call' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さを 足す\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error for a return inside an if condition' do
      mock_reader(
        "もし 1を 返す\n" \
        "　・・・\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error on an unfinished if statement with properties' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さ\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error on a sudden if statement with properties (by token sequence)' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さが 0？ ならば\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error on an if statement into multiple comp_1' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さが あれの 長さが あれの 長さ？ ならば\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error on an unexpected array with properties' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さ、1\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error when assigning a variable to itself' do
      mock_reader(
        "ホゲは ホゲ\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end

    it 'raises an error on a question after an property outside of assignment' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さ？\n"
      )
      expect_error Tokenizer::Errors::UnexpectedInput
    end
  end
end
