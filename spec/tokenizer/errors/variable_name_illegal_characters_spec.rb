require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error when a variable name includes an illegal character' do
      %w[￥ｎ 【 】].each do |illegal_char|
        mock_reader(
          "あ#{illegal_char}いは 1\n"
        )
        expect_error Tokenizer::Errors::VariableNameIllegalCharacters
      end
    end
  end
end
