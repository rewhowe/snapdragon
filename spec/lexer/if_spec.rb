require './src/lexer.rb'
require './src/token.rb'
require './spec/contexts/lexer.rb'

RSpec.describe Lexer, 'values' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'tokenizes if statements' do
      write_test_file [
        'もし 1が 1と同じ ならば',
        '　・・・'
      ]

      expect(tokens).to contain_exactly(
        [Token::IF_START, nil],
        [Token::COMPARATOR_1, '1'],
        [Token::COMPARATOR_2, '1'],
        [Token::IF_END, nil],
        [Token::SCOPE_BEGIN, nil],
        [Token::NO_OP, nil],
        [Token::SCOPE_CLOSE, nil],
      )
    end

    it 'closes  if statement scope when next-line token unrelated' do
      write_test_file [
        'もし 1が 1と同じ ならば',
        '　・・・',
        'ほげは 1',
      ]

      expect(tokens).to contain_exactly(
        [Token::IF_START, nil],
        [Token::COMPARATOR_1, '1'],
        [Token::COMPARATOR_2, '1'],
        [Token::IF_END, nil],
        [Token::SCOPE_BEGIN, nil],
        [Token::NO_OP, nil],
        [Token::SCOPE_CLOSE, nil],
        [Token::ASSIGNMENT, 'ほげ'],
        [Token::VARIABLE, '1'],
      )
    end
  end
end
