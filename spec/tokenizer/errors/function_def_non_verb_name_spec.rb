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
    it 'raises an error when declaring non-verb-like function' do
      mock_reader(
        "ポテトとは\n" \
        "　これは 「食べ物」\n"
      )
      expect_error FunctionDefNonVerbName
    end
  end
end
