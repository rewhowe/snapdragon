require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error on EOF when expecting more tokens' do
      mock_reader(
        'ホゲは'
      )
      expect_error Tokenizer::Errors::UnexpectedEof
    end

    it 'raises an error on an unfinished list (followed by EOF)' do
      mock_reader(
        "ハイレツは 1、\n" \
        "2、\n" \
        '3、'
      )
      expect_error Tokenizer::Errors::UnexpectedEof
    end

    it 'raises an error on an unfinished list (followed by eol and EOF)' do
      mock_reader(
        "ハイレツは 1、\n" \
        "2、\n" \
        "3、\n"
      )
      expect_error Tokenizer::Errors::UnexpectedEof
    end

    it 'raises an error on an unclosed string interpolation' do
      mock_reader(
        "「【」を 言う\n"
      )
      expect_error Tokenizer::Errors::UnexpectedEof
    end
  end
end
