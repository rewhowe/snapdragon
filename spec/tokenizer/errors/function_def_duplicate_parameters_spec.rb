require './src/tokenizer/lexer.rb'
require './src/tokenizer/errors.rb'

require './spec/contexts/lexer.rb'
require './spec/contexts/errors.rb'

include Tokenizer
include Errors

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'
  include_context 'errors'

  describe '#next_token' do
    it 'raises an error when function def contains duplicate parameters' do
      mock_reader(
        "ほげと ほげを ふがるとは\n"
      )
      expect_error FunctionDefDuplicateParameters
    end
  end
end
