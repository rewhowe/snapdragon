require './src/tokenizer/lexer.rb'
require './src/tokenizer/errors.rb'

require './spec/contexts/lexer.rb'
require './spec/contexts/errors.rb'

include Tokenizer
include Errors

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'
  include_context 'errors'

  describe '#next_token' do
    it 'raises an error when too much indent' do
      mock_reader(
        "インデントしすぎるとは\n" \
        "　　行頭の空白は 「多い」\n"
      )
      expect_error UnexpectedIndent
    end
  end
end
