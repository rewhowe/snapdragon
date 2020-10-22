require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'
require './spec/contexts/errors'

include Tokenizer
include Errors

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'
  include_context 'errors'

  describe '#next_token' do
    it 'raises an error for unclosed block comments' do
      mock_reader(
        "※このブロックコメントは曖昧\n"
      )
      expect_error UnclosedBlockComment
    end
  end
end
