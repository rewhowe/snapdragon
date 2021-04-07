require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error for undeclared variables in if statements' do
      mock_reader(
        "もし ほげが 1と おなじ ならば\n"
      )
      expect_error Tokenizer::Errors::VariableDoesNotExist
    end

    it 'raises an error for undeclared variables in function calls' do
      mock_reader(
        "配列に ほげを 追加する\n"
      )
      expect_error Tokenizer::Errors::VariableDoesNotExist
    end

    it 'raises an error for undeclared variables in loops' do
      mock_reader(
        "ホゲから フガまで 繰り返す\n"
      )
      expect_error Tokenizer::Errors::VariableDoesNotExist
    end

    it 'raises an error on a non-existent return parameter' do
      mock_reader(
        "存在しない変数を 返す\n"
      )
      expect_error Tokenizer::Errors::VariableDoesNotExist
    end
  end
end
