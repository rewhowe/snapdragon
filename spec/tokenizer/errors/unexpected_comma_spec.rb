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
    it 'raises an error on an unexpected array with properties' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さ、1\n"
      )
      expect_error UnexpectedComma
    end

    it 'raises an error on a comma inside an if statement' do
      mock_reader(
        "もし 1が 2？、2？ ならば\n"
      )
      expect_error UnexpectedComma
    end
  end
end
