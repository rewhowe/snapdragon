require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#interpolate_string' do
    it 'raises an error for string interpolation with a primitive' do
      expect_string_interpolation_error '【】', Tokenizer::Errors::EmptyOrUnclosedInterpolation
    end

    it 'raises an error for unclosed string interpolation' do
      expect_string_interpolation_error '【ホゲ', Tokenizer::Errors::EmptyOrUnclosedInterpolation
    end
  end
end
