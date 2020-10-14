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
    it 'raises an error on an assignment into function call' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さを 足す\n"
      )
      expect_error UnexpectedFunctionCall
    end
  end
end
