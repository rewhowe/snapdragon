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
    it 'raises an error for next inside an unexpected scope' do
      mock_reader(
        "ほげるとは\n" \
        "　次\n"
      )
      expect_error UnexpectedScope
    end

    it 'raises an error for break inside an unexpected scope' do
      mock_reader(
        "ほげるとは\n" \
        "　終わり\n"
      )
      expect_error UnexpectedScope
    end
  end
end
