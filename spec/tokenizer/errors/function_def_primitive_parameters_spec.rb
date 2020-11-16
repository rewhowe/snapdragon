require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error when function def contains value' do
      mock_reader(
        "1を ほげるとは\n"
      )
      expect_error Tokenizer::Errors::FunctionDefPrimitiveParameters
    end
  end
end
