require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error for doubly-escaped strings' do
      expect do
        mock_reader(
          '「ほげ\\\\」」を 言う'
        )
      end .to raise_error Tokenizer::Errors::MalformedString
    end

    it 'raises an error for quadruply-escaped strings (and 6, 8, etc...)' do
      expect do
        mock_reader(
          '「ほげ\\\\\\\\」」を 言う'
        )
      end .to raise_error Tokenizer::Errors::MalformedString
    end
  end
end
