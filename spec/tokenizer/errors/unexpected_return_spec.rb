require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error for an explicit return without parameters' do
      mock_reader(
        "なる\n" \
      )
      expect_error Tokenizer::Errors::UnexpectedReturn
    end
  end
end
