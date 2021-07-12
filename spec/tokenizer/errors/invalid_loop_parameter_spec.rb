require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error for an invalid loop iterator parameter (non-existent variable)' do
      mock_reader(
        "存在しない変数に 対して 繰り返す\n"
      )
      expect_error Tokenizer::Errors::InvalidLoopParameter
    end

    it 'raises an error for an invalid loop iterator parameter (non-string primitive)' do
      mock_reader(
        "1に 対して 繰り返す\n"
      )
      expect_error Tokenizer::Errors::InvalidLoopParameter
    end

    it 'raises an error when looping over a non-iterable property' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さに 対して 繰り返す\n"
      )
      expect_error Tokenizer::Errors::InvalidLoopParameter
    end
  end
end
