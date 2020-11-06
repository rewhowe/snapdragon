require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'
require './spec/contexts/errors'

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'
  include_context 'errors'

  describe '#next_token' do
    it 'raises an error when function def contains value' do
      mock_reader(
        "1を ほげるとは\n"
      )
      expect_error FunctionDefPrimitiveParameters
    end
  end
end
