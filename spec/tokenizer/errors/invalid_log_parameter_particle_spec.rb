require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error for an invalid log particle' do
      mock_reader(
        "2で 底と する 1000の 対数\n"
      )
      expect_error Tokenizer::Errors::InvalidLogParameterParticle
    end
  end
end
