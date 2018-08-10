require './src/lexer.rb'
require './src/token.rb'

RSpec.describe Lexer do
  describe '#tokenize' do
    it 'tokenizes variable declarations' do
      file = make_test_file [
        'ほげは 10',
      ]

      tokens = Lexer::tokenize(file).map { |token| [token.type, token.content] }

      expect(tokens).to contain_exactly(
        [ Token::ASSIGNMENT, 'ほげ' ],
        [ Token::VARIABLE, '10' ],
      )
    end
  end
end
