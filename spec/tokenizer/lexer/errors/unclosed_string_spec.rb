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
    it 'raises an error for unclosed strings in variable declarations' do
      mock_reader(
        "変数はは 「もじれつ\n"
      )
      expect_error UnclosedString
    end

    it 'raises an error for unclosed strings parameters' do
      mock_reader(
        "モジレツを 読むとは\n" \
        "　・・・\n" \
        "「もじれつを 読む\n"
      )
      expect_error UnclosedString
    end
  end
end
