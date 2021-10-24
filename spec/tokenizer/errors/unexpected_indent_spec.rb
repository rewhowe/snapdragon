require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error when too much indent' do
      mock_reader(
        "インデントしすぎるとは\n" \
        "　　行頭の空白は 「多い」\n"
      )
      expect_error Tokenizer::Errors::UnexpectedIndent
    end

    it 'raises an error when the BOF is indented' do
      mock_reader(
        "　ホゲは 1\n"
      )
      expect_error Tokenizer::Errors::UnexpectedIndent
    end
  end
end
