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
    it 'raises an error for a return inside an if condition' do
      mock_reader(
        "もし 1を 返す\n" \
        "　・・・\n"
      )
      expect_error UnexpectedReturn
    end

    it 'raises an error for an explicit return without parameters' do
      mock_reader(
        "なる\n" \
      )
      expect_error UnexpectedReturn
    end

    it 'raises an error on an assignment into if return' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さを 返す\n"
      )
      expect_error UnexpectedReturn
    end
  end
end
