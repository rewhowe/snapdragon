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
    it 'raises an error when declaring function inside if statement' do
      mock_reader(
        "もし 引数を ほげるとは\n"
      )
      expect_error UnexpectedFunctionDef
    end

    it 'raises an error when declaring function inside a loop' do
      mock_reader(
        "繰り返す\n" \
        "　引数を ほげるとは\n"
      )
      expect_error UnexpectedFunctionDef
    end
  end
end
