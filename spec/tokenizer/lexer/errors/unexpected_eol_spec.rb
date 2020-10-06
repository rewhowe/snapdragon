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
    it 'raises an error on unexpected EOL' do
      mock_reader(
        "変数は 1、\n"
      )
      expect_error UnexpectedEol
    end

    it 'raises an error when missing tokens' do
      mock_reader(
        "変数は\n"
      )
      expect_error UnexpectedEol
    end

    it 'raises an error for unclosed if statements' do
      mock_reader(
        "もし 「ほげ」と 言う？\n"
      )
      expect_error UnexpectedEol
    end

    it 'raises an error for comments in if statements' do
      mock_reader(
        "もし 「ほげ」と 言う（コメント\n"
      )
      expect_error UnexpectedEol
    end
  end
end
