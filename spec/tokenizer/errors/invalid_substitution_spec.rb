require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#interpolate_string' do
    it 'raises an error for string interpolation with a primitive number' do
      expect_string_interpolation_error '【1】', Tokenizer::Errors::InvalidSubstitution
    end

    it 'raises an error for string interpolation with a primitive string' do
      expect_string_interpolation_error '【「ほげ」】', Tokenizer::Errors::InvalidSubstitution
    end

    it 'raises an error for string interpolation with a primitive possessive' do
      expect_string_interpolation_error '【「ほげ」の 文字数】', Tokenizer::Errors::InvalidSubstitution
    end
  end
end
