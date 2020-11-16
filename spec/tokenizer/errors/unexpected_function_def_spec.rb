require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error when declaring function inside a loop' do
      mock_reader(
        "繰り返す\n" \
        "　引数を ほげるとは\n"
      )
      expect_error Tokenizer::Errors::UnexpectedFunctionDef
    end
  end
end
