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
    it 'raises an error for an invalid loop iterator particle' do
      mock_reader(
        "「永遠」を 対して 繰り返す\n"
      )
      expect_error InvalidLoopParameterParticle
    end

    it 'raises an error for invalid loop parameter particle (1)' do
      mock_reader(
        "1に 3まで 繰り返す\n"
      )
      expect_error InvalidLoopParameterParticle
    end

    it 'raises an error for invalid loop parameter type (1)' do
      mock_reader(
        "「1」から 3まで 繰り返す\n"
      )
      expect_error InvalidLoopParameterParticle
    end

    it 'raises an error for invalid loop parameter particle (2)' do
      mock_reader(
        "1から 100に 繰り返す\n"
      )
      expect_error InvalidLoopParameterParticle
    end

    it 'raises an error for invalid loop parameter type (2)' do
      mock_reader(
        "1から 「100」まで 繰り返す\n"
      )
      expect_error InvalidLoopParameterParticle
    end
  end
end
