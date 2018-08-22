require './src/lexer.rb'
require './src/token.rb'
require './spec/contexts/lexer.rb'

RSpec.describe Lexer, 'assignment' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'tokenizes variable declarations' do
      write_test_file [
        'ほげは 10',
      ]

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ'],
        [Token::VARIABLE, '10'],
      )
    end

    it 'can assign variables to other variables' do
      write_test_file [
        'ほげは 10',
        'ふがは ほげ',
      ]

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ'], [Token::VARIABLE, '10'],
        [Token::ASSIGNMENT, 'ふが'], [Token::VARIABLE, 'ほげ'],
      )
    end
  end
end
