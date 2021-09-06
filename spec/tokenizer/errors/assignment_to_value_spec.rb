require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error when assigning to value' do
      mock_reader(
        "1は 2\n"
      )
      expect_error Tokenizer::Errors::AssignmentToValue
    end

    it 'raises an error when assigning to the property of a value' do
      mock_reader(
        "「あ」の 1つ目は 2\n"
      )
      expect_error Tokenizer::Errors::AssignmentToValue
    end
  end
end
