require './src/tokenizer/lexer.rb'
require './src/tokenizer/errors.rb'

require './spec/contexts/lexer.rb'
require './spec/contexts/errors.rb'

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

    it 'raises an error for multiple loop iterator parameters' do
      mock_reader(
        "あれは 配列\n" \
        "1に 「ほげ」に 対して 繰り返す\n"
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
  end
end
