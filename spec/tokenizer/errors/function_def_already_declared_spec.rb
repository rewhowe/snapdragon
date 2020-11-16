require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error when re-declaring a function' do
      mock_reader(
        "言葉を 言うとは\n"
      )
      expect_error Tokenizer::Errors::FunctionDefAlreadyDeclared
    end

    it 'raises an error when re-declaring a function regardless of parameter order' do
      mock_reader(
        "ほげと ふがを ぴよるとは\n" \
        "　・・・\n" \
        "ふがと ほげを ぴよるとは\n" \
        "　・・・\n"
      )
      expect_error Tokenizer::Errors::FunctionDefAlreadyDeclared
    end
  end
end
