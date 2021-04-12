require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    # TODO: (feature/additional-math) Uncomment this test (presently impossible)
    # it 'raises an error when checking inside a non-container' do
    #   mock_reader(
    #     "もし 1が 真の 中に あれば\n"
    #   )
    #   expect_error Tokenizer::Errors::NotAValidContainer
    # end
  end
end
