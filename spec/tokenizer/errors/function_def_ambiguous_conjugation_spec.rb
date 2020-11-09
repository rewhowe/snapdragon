require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error when declaring a function with an ambiguous conjugation' do
      mock_reader(
        "商品を かうとは\n" \
        "　・・・\n" \
        "草を かるとは\n" \
        "　・・・\n"
      )
      expect_error Tokenizer::Errors::FunctionDefAmbiguousConjugation
    end
  end
end
