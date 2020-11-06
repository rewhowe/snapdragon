require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'
require './spec/contexts/errors'

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
