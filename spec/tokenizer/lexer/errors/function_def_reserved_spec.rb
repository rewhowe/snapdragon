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
    it 'raises an error for defining a method with a reserved name' do
      mock_reader(
        "エラーを 繰り返すとは\n"
      )
      expect_error FunctionDefReserved
    end
  end
end
