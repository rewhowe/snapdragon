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
    it 'raises an error when too much indent' do
      mock_reader(
        "インデントしすぎるとは\n" \
        "　　行頭の空白は 「多い」\n"
      )
      expect_error UnexpectedIndent
    end

    it 'raises an error when the BOF is indented' do
      expect do
        mock_reader(
          "　ホゲは 1\n"
        )
      end .to raise_error UnexpectedIndent
    end
  end
end
