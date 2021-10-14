require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error for unclosed block comments' do
      mock_reader(
        "(このブロックコメントは曖昧\n"
      )
      expect_error Tokenizer::Errors::UnclosedBlockComment
    end
  end
end
