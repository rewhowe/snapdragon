require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error when declaring non-verb-like function' do
      mock_reader(
        "ポテトとは\n" \
        "　これは 「食べ物」\n"
      )
      expect_error Tokenizer::Errors::FunctionDefNonVerbName
    end
  end
end
