require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error for declaring a variable with a reserved name' do
      mock_reader(
        "空は 10\n"
      )
      expect_error Tokenizer::Errors::VariableNameReserved
    end

    it 'raises an error for declaring a parameter with a reserved name' do
      mock_reader(
        "空を 測るとは\n" \
        "　・・・\n"
      )
      expect_error Tokenizer::Errors::VariableNameReserved
    end
  end
end
