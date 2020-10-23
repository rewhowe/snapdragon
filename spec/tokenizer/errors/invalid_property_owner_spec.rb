require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'
require './spec/contexts/errors'

include Tokenizer
include Errors

# TODO: move up a folder
RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'
  include_context 'errors'

  describe '#next_token' do
    it 'raises an error when property owner is not a variable or string' do
      mock_reader(
        "ほげは 1の 長さ\n"
      )
      expect_error InvalidPropertyOwner
    end

    it 'raises an error when a property owner cannot yield a valid attribute as a loop iterator parameter' do
      mock_reader(
        "「ほげ」の 長さに 対して 繰り返す\n"
      )
      expect_error InvalidPropertyOwner
    end
  end
end
