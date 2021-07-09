require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error for a non-numeric loop parameter type (1)' do
      mock_reader(
        "「1」から 3まで 繰り返す\n"
      )
      expect_error Tokenizer::Errors::NotANumericParameter
    end

    it 'raises an error for a non-numeric loop parameter type (2)' do
      mock_reader(
        "1から 「100」まで 繰り返す\n"
      )
      expect_error Tokenizer::Errors::NotANumericParameter
    end

    it 'raises an error for non-numeric logarithm base' do
      mock_reader(
        "「100」を 底と する 1の 対数\n"
      )
      expect_error Tokenizer::Errors::NotANumericParameter
    end

    it 'raises an error for non-numeric logarithm argument' do
      mock_reader(
        "2を 底と する 「ほげ」の 対数\n"
      )
      expect_error Tokenizer::Errors::NotANumericParameter
    end
  end
end
