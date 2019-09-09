require './src/tokenizer/lexer.rb'
require './src/tokenizer/token.rb'
require './spec/contexts/lexer.rb'

include Tokenizer

RSpec.describe Lexer, 'assignment' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'tokenizes variable declarations' do
      mock_reader(
        "ほげは 10\n",
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ'], [Token::VARIABLE, '10'], [Token::EOL],
      )
    end

    it 'can assign variables to other variables' do
      mock_reader(
        "ほげは 10\n" \
        "ふがは ほげ\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ'], [Token::VARIABLE, '10'], [Token::EOL],
        [Token::ASSIGNMENT, 'ふが'], [Token::VARIABLE, 'ほげ'], [Token::EOL],
      )
    end
  end
end
