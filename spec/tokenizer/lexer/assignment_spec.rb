require './src/tokenizer/lexer.rb'
require './src/tokenizer/token.rb'
require './spec/contexts/lexer.rb'

include Tokenizer

RSpec.describe Lexer, 'assignment' do
  include_context 'lexer'

  describe '#next_token' do
    it 'tokenizes variable declarations' do
      mock_reader(
        "ほげは 10\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE], [Token::VARIABLE, '10', Token::VAR_NUM],
      )
    end

    it 'can assign variables to other variables' do
      mock_reader(
        "ほげは 10\n" \
        "ふがは ほげ\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE], [Token::VARIABLE, '10', Token::VAR_NUM],
        [Token::ASSIGNMENT, 'ふが', Token::VARIABLE], [Token::VARIABLE, 'ほげ', Token::VARIABLE],
      )
    end
  end
end
