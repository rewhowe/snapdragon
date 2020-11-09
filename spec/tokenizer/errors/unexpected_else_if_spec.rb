require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error for else-if without if' do
      mock_reader(
        "または 「ほげ」と 言う（コメント\n"
      )
      expect_error Tokenizer::Errors::UnexpectedElseIf
    end
  end
end
