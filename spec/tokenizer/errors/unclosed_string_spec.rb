require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error for unclosed strings in variable declarations' do
      mock_reader(
        "変数はは 「もじれつ\n"
      )
      expect_error Tokenizer::Errors::UnclosedString
    end

    it 'raises an error for unclosed strings parameters' do
      mock_reader(
        "モジレツを 読むとは\n" \
        "　・・・\n" \
        "「もじれつを 読む\n"
      )
      expect_error Tokenizer::Errors::UnclosedString
    end
  end
end
