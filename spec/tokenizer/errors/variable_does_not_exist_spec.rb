require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'
require './spec/contexts/errors'

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'
  include_context 'errors'

  describe '#next_token' do
    it 'raises an error for undeclared variables in if statements' do
      mock_reader(
        "もし ほげが 1と 等しければ\n"
      )
      expect_error VariableDoesNotExist
    end

    it 'raises an error for undeclared variables in function calls' do
      mock_reader(
        "配列に ほげを 追加する\n"
      )
      expect_error VariableDoesNotExist
    end

    describe '#next_token' do
      it 'raises an error on a non-existent return parameter' do
        mock_reader(
          "存在しない変数を 返す\n"
        )
        expect_error VariableDoesNotExist
      end
    end
  end
end
