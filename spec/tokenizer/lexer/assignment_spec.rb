require './src/token'
require './src/tokenizer/lexer'
require './spec/contexts/lexer'

include Tokenizer

RSpec.describe Lexer, 'assignment' do
  include_context 'lexer'

  describe '#next_token' do
    it 'tokenizes variable declarations' do
      mock_reader(
        "ほげは 10\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE], [Token::RVALUE, '10', Token::VAL_NUM],
      )
    end

    it 'can assign variables to other variables' do
      mock_reader(
        "ほげは 10\n" \
        "ふがは ほげ\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE], [Token::RVALUE, '10', Token::VAL_NUM],
        [Token::ASSIGNMENT, 'ふが', Token::VARIABLE], [Token::RVALUE, 'ほげ', Token::VARIABLE],
      )
    end
  end
end
