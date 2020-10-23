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
    it 'raises an error for else-if without if' do
      mock_reader(
        "または 「ほげ」と 言う（コメント\n"
      )
      expect_error UnexpectedElseIf
    end
  end
end
