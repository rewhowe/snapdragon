require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error when a property owner cannot yield a valid property as a loop iterator parameter' do
      mock_reader(
        "「ほげ」の 長さに 対して 繰り返す\n"
      )
      expect_error Tokenizer::Errors::InvalidPropertyOwner
    end
  end
end
