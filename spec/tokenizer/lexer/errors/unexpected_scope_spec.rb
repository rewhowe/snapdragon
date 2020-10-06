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
    it 'raises an error for next inside an unexpected scope' do
      mock_reader(
        "ほげるとは\n" \
        "　次\n"
      )
      expect_error UnexpectedScope
    end
  end
end
