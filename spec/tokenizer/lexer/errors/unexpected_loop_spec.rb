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
    it 'raises an error for an unexpected loop parameter' do
      mock_reader(
        "「永遠」に 繰り返す\n"
      )
      expect_error UnexpectedLoop
    end

    it 'raises an error for a loop inside an if condition' do
      mock_reader(
        "もし 「あいうえお」に 対して 繰り返す\n"
      )
      expect_error UnexpectedLoop
    end
  end
end
