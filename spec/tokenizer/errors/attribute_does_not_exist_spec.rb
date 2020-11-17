require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    # Covers function call, loop, loop iterator, and return
    it 'raises an error when property is invalid (parameter)' do
      mock_reader(
        "あれは 配列\n" \
        "あれの ふがに 対して 繰り返す\n"
      )
      expect_error Tokenizer::Errors::AttributeDoesNotExist
    end
  end
end
