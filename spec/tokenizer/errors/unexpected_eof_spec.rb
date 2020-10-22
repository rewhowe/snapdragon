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
    it 'raises an error on EOF when expecting more tokens' do
      mock_reader(
        'ホゲは'
      )
      expect_error UnexpectedEof
    end

    it 'raises an error on an unfinished list (followed by EOF)' do
      mock_reader(
        "ハイレツは 1、\n" \
        "2、\n" \
        '3、'
      )
      expect_error UnexpectedEof
    end

    it 'raises an error on an unfinished list (followed by eol and EOF)' do
      mock_reader(
        "ハイレツは 1、\n" \
        "2、\n" \
        "3、\n"
      )
      expect_error UnexpectedEof
    end
  end
end
