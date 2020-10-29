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
    it 'raises an error for an invalid loop iterator parameter (non-existent variable)' do
      mock_reader(
        "存在しない変数に 対して 繰り返す\n"
      )
      expect_error InvalidLoopParameter
    end

    it 'raises an error for an invalid loop iterator parameter (non-string primitive)' do
      mock_reader(
        "1に 対して 繰り返す\n"
      )
      expect_error InvalidLoopParameter
    end

    it 'raises an error for invalid loop parameter type (1)' do
      mock_reader(
        "「1」から 3まで 繰り返す\n"
      )
      expect_error InvalidLoopParameter
    end

    it 'raises an error for invalid loop parameter type (2)' do
      mock_reader(
        "1から 「100」まで 繰り返す\n"
      )
      expect_error InvalidLoopParameter
    end

    it 'raises an error when looping over a length attribute' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さに 対して 繰り返す\n"
      )
      expect_error InvalidLoopParameter
    end
  end
end
