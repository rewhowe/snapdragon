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
    it 'raises an error on an if statement into multiple comp1' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さが あれの 長さが あれの 長さ？ ならば\n"
      )
      expect_error InvalidPropertyComparison
    end
  end
end
