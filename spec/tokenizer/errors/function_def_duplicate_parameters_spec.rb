require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error when function def contains duplicate parameters' do
      mock_reader(
        "ほげと ほげを ふがるとは\n"
      )
      expect_error Tokenizer::Errors::FunctionDefDuplicateParameters
    end
  end
end
