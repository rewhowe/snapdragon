require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error when a comparison is missing operands' do
      mock_reader(
        "もし 1より 大きければ\n"
      )
      expect_error Tokenizer::Errors::InvalidComparison
    end
  end
end
