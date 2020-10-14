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
    it 'raises an error for declaring a variable with a name already declared as a function' do
      mock_reader(
        "ほげるとは\n" \
        "　・・・\n" \
        "ほげるは 10\n"
      )
      expect_error VariableNameAlreadyDelcaredAsFunction
    end
  end
end
