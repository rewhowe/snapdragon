require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error when accessing a property that cannot belong to a string' do
      mock_reader(
        "ホゲは 「ほげ」の キー列\n"
      )
      expect_error Tokenizer::Errors::InvalidStringProperty
    end
  end
end
