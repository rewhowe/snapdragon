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
    it 'raises an error when re-declaring a function' do
      mock_reader(
        "言葉を 言うとは\n"
      )
      expect_error FunctionDefAlreadyDeclared
    end

    it 'raises an error when re-declaring a function regardless of parameter order' do
      mock_reader(
        "ほげと ふがを ぴよるとは\n" \
        "　・・・\n" \
        "ふがと ほげを ぴよるとは\n" \
        "　・・・\n"
      )
      expect_error FunctionDefAlreadyDeclared
    end
  end
end