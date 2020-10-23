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
    it 'raises an error for a return with the wrong particle (返す)' do
      mock_reader(
        "1に 返す\n"
      )
      expect_error InvalidReturnParameterParticle
    end

    it 'raises an error for a return with the wrong particle (なる)' do
      mock_reader(
        "1を なる\n"
      )
      expect_error InvalidReturnParameterParticle
    end

    it 'raises an error for a return with an unnecessary particle (返る)' do
      mock_reader(
        "1に 返る\n"
      )
      expect_error InvalidReturnParameterParticle
    end
  end
end
