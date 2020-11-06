require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'
require './spec/contexts/errors'

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
