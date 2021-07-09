require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error when checking if a valid is inside a non-container' do
      mock_reader(
        "もし 1が 1の 中に あれば\n"
      )
      expect_error Tokenizer::Errors::NotAValidContainer
    end
  end
end
