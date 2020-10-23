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
    it 'raises an error on a sudden if statement with properies (by close if check)' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さより 高ければ\n"
      )
      expect_error UnexpectedComparison
    end

    it 'raises an error on an assignment into if statement' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さ？ ならば\n"
      )
      expect_error UnexpectedComparison
    end
  end
end
