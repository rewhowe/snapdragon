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
    it 'raises an error when property is invalid (attribute)' do
      mock_reader(
        "あれは 配列\n" \
        "ほげは あれの ふが\n"
      )
      expect_error AttributeDoesNotExist
    end

    # Covers function call, loop, loop iterator, and return
    it 'raises an error when property is invalid (parameter)' do
      mock_reader(
        "あれは 配列\n" \
        "あれの ふがに 対して 繰り返す\n"
      )
      expect_error AttributeDoesNotExist
    end
  end
end
