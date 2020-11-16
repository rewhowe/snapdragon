require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error for defining a method with a reserved name' do
      mock_reader(
        "エラーを 繰り返すとは\n"
      )
      expect_error Tokenizer::Errors::FunctionDefReserved
    end
  end
end
