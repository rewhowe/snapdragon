require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error for an invalid loop iterator particle' do
      mock_reader(
        "「永遠」を 対して 繰り返す\n"
      )
      expect_error Tokenizer::Errors::InvalidLoopParameterParticle
    end

    it 'raises an error for invalid loop parameter particle (1)' do
      mock_reader(
        "1に 3まで 繰り返す\n"
      )
      expect_error Tokenizer::Errors::InvalidLoopParameterParticle
    end

    it 'raises an error for invalid loop parameter particle (2)' do
      mock_reader(
        "1から 100に 繰り返す\n"
      )
      expect_error Tokenizer::Errors::InvalidLoopParameterParticle
    end
  end
end
