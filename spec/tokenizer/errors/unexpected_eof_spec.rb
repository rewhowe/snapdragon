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
    it 'raises an error on an unfinished list (followed by eof)' do
      mock_reader(
        "ハイレツは 1、\n" \
        "2、\n" \
        '3、'
      )
      expect_error UnexpectedEof
    end

    it 'raises an error on an unfinished list (followed by eol and eof)' do
      mock_reader(
        "ハイレツは 1、\n" \
        "2、\n" \
        "3、\n"
      )
      expect_error UnexpectedEof
    end
  end
end
