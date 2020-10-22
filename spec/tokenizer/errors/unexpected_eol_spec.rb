require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'
require './spec/contexts/errors'

include Tokenizer
include Errors

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'
  include_context 'errors'

  describe '#next_token' do
    it 'raises an error on an unfinished list (followed by newline)' do
      mock_reader(
        "変数は 1、\n\n"
      )
      expect_error UnexpectedEol
    end

    it 'raises an error when missing tokens' do
      mock_reader(
        "変数は\n"
      )
      expect_error UnexpectedEol
    end

    it 'raises an error for unclosed if statements' do
      mock_reader(
        "もし 「ほげ」と 言う？\n"
      )
      expect_error UnexpectedEol
    end

    it 'raises an error for comments in if statements' do
      mock_reader(
        "もし 「ほげ」と 言う（コメント\n"
      )
      expect_error UnexpectedEol
    end

    it 'raises an error for incomplete loop iterators' do
      mock_reader(
        "「あいうえお」に 対して\n"
      )
      expect_error UnexpectedEol
    end
  end
end
