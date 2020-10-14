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
    it 'raises an error for trailing characters after bang' do
      mock_reader(
        "ほげるとは\n" \
        "　・・・\n" \
        "ほげる！ あと何かをする\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error on trailing characters after funtion def' do
      mock_reader(
        "ほげるとは 何かな？\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when function def contains array' do
      mock_reader(
        "ほげ、ふが、ぴよを ほげる\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when missing parameters in function call' do
      mock_reader(
        "タベモノを 食べるとは\n" \
        "　・・・\n" \
        "食べる\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when wrong parameters in function call' do
      mock_reader(
        "タベモノを 食べるとは\n" \
        "　・・・\n" \
        "1で 食べる\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when calling function nonexistent in scope' do
      mock_reader(
        "ほげるとは\n" \
        "　ふがるとは\n" \
        "　　・・・\n" \
        "ふがる\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when calling function with wrong particles' do
      mock_reader(
        "タベモノを 食べるとは\n" \
        "　・・・\n" \
        "「ポテト」に 食べる\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when function call contains array primitive' do
      mock_reader(
        "1、2、3に 4を 追加する\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error for a return with multiple parameters' do
      mock_reader(
        "1と 2を 返す\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error for undeclared variables in if statements' do
      mock_reader(
        "もし ほげが 1と 等しければ\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error for missing loop iterator parameter' do
      mock_reader(
        "対して 繰り返す\n"
      )
      expect_error UnexpectedInput
    end
  end
end
