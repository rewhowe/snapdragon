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
    it 'raises an error on property inside function def' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さを ほげるとは\n"
      )
      expect_error InvalidFunctionDefParameter
    end

    it 'raises an error on an assignment into function def' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さを ほげるとは\n"
      )
      expect_error InvalidFunctionDefParameter
    end
  end
end
