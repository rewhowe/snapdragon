require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error for else without if' do
      mock_reader(
        "それ以外は\n"
      )
      expect_error Tokenizer::Errors::UnexpectedElse
    end
  end
end
