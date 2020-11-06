require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'
require './spec/contexts/errors'

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'
  include_context 'errors'

  describe '#next_token' do
    it 'raises an error when declaring a function with an ambiguous conjugation' do
      mock_reader(
        "商品を かうとは\n" \
        "　・・・\n" \
        "草を かるとは\n" \
        "　・・・\n"
      )
      expect_error FunctionDefAmbiguousConjugation
    end
  end
end
