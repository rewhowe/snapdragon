require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'on an expected line break' do
      expect do
        mock_reader(
          "ほげ\\は 1\n"
        )
      end .to raise_error Tokenizer::Errors::UnexpectedLineBreak
    end
  end
end
