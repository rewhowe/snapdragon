require './src/tokenizer/lexer.rb'
require './src/tokenizer/errors.rb'

require './spec/contexts/lexer.rb'
require './spec/contexts/errors.rb'

include Tokenizer
include Errors

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'
  include_context 'errors'

  # TODO: split up into individual errors
  describe '#next_token' do
    it 'raises an error when property owner is not a variable or string' do
      mock_reader(
        "ほげは 1の 長さ\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when property owner does not exist' do
      mock_reader(
        "ほげは ふがの 長さ\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when property is invalid' do
      mock_reader(
        "あれは 配列\n" \
        "ほげは あれの ほげ\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when property is read-only' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さは 1\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when looping over a length attribute' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さに 対して 繰り返す\n"
      )
      expect_error UnexpectedInput
    end

    # TODO: (v1.1.0)
    # it 'raises an error on an assignment into assignment' do
    #   mock_reader(
    #     "あれは 連想配列\n" \
    #     "あれは あれの 「ほげ」は 1\n"
    #   )
    #   expect_error UnexpectedInput
    # end

    it 'raises an error on an assignment into function def' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さを ほげるとは\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error on an assignment into function call' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さを 足す\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error on an assignment into if statement' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さ？ ならば\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error on property inside function def' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さを ほげるとは\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error on an unfinished if statement with properies' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さ\n"
      )
      expect_error UnexpectedInput
    end

    # TODO: (v1.1.0)
    # it 'raises an error on an if statement into assignment' do
    #   mock_reader(
    #     "あれは 連想配列\n" \
    #     "もし あれの 「ホゲ」は 1\n"
    #   )
    #   expect_error UnexpectedInput
    # end

    it 'raises an error on an if statement into function def ' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さを ほげるとは\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error on an if statement into loop' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さに 対して 繰り返す\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error on an if statement into multiple comp1' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さが あれの 長さが あれの 長さ？ ならば\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error on indexing a string with a string' do
      mock_reader(
        "ホゲは 「ホゲ」の 「ホゲ」\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when assigning a variable to itself' do
      mock_reader(
        "ホゲは ホゲ\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when assigning a property owner to itself' do
      mock_reader(
        "ホゲは ホゲの 長さ\n"
      )
      expect_error UnexpectedInput
    end

    # TODO: (v1.1.0)
    # it 'raises an error when assigning an attribute to itself' do
    #   mock_reader(
    #     "ホゲは 連想配列\n" \
    #     "フガは ホゲの フガ\n"
    #   )
    # end

    # TODO: (v1.1.0)
    # it 'raises an error when assigning a key to itself' do
    #   mock_reader(
    #     "ホゲは 連想配列\n" \
    #     "フガは ホゲの フガ\n"
    #   )
    # end
  end
end
