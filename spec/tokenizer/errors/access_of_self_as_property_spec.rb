require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#interpolate_string' do
    it 'raises an error for string interpolation including access of self as property' do
      expect_string_interpolation_error '【ホゲの ホゲ】', Tokenizer::Errors::AccessOfSelfAsProperty
    end

    it 'raises an error when assigning a value to self access of self' do
      mock_reader(
        "ホゲは 配列\n" \
        "ホゲの ホゲは 1\n"
      )
      expect_error Tokenizer::Errors::AccessOfSelfAsProperty
    end

    it 'raises an error when assigning self access of self' do
      mock_reader(
        "ホゲは 配列\n" \
        "フガは ホゲの ホゲ\n"
      )
      expect_error Tokenizer::Errors::AccessOfSelfAsProperty
    end
  end
end
