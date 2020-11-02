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
    it 'raises an error for declaring a function with a name already declared as a variable' do
      mock_reader(
        "ほげるは 10\n" \
        "ほげるとは\n" \
        "　・・・\n"
      )
      expect_error FunctionNameAlreadyDelcaredAsVariable
    end
  end
end
