require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

# Contains various tests for partial implementations of future features.
# Tests may come and go from this file and may not be 'active'.
RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    # TODO: (v1.1.0)
    # it 'raises an error on indexing a string with a string' do
    #   mock_reader(
    #     "ホゲは 「ホゲ」の 「フガ」\n"
    #   )
    #   expect_error Tokenizer::Errors::InvalidStringProperty
    # end
  end
end
