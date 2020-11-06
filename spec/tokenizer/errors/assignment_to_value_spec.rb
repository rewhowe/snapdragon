require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'
require './spec/contexts/errors'

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'
  include_context 'errors'

  describe '#next_token' do
    it 'raises an error when assigning to value' do
      mock_reader(
        "1は 2\n"
      )
      expect_error AssignmentToValue
    end
  end
end
