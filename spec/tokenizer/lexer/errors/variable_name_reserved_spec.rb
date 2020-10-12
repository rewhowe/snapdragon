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
    it 'raises an error for declaring a variable with a reserved name' do
      mock_reader(
        "大きさは 10\n"
      )
      expect_error VariableNameReserved
    end

    it 'raises an error for declaring a parameter with a reserved name' do
      mock_reader(
        "長さを 測るとは\n" \
        "　・・・\n"
      )
      expect_error VariableNameReserved
    end
  end
end
