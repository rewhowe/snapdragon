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
    it 'raises an error on trailing characters in array declaration' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さ？\n"
      )
      expect_error UnexpectedQuestion
    end
  end
end
