require './src/token'
require './src/tokenizer/lexer'
require './spec/contexts/lexer'

include Tokenizer

RSpec.describe Lexer, 'misc' do
  include_context 'lexer'

  describe '#next_token' do
    it 'tokenizes no-op' do
      mock_reader(
        "・・・\n"
      )
      expect(tokens).to contain_exactly_in_order(
        [Token::NO_OP]
      )
    end

    it 'tokenizes debug' do
      mock_reader(
        "蛾\n"
      )
      expect(tokens).to contain_exactly_in_order(
        [Token::DEBUG]
      )
    end

    it 'tokenizes debug!' do
      mock_reader(
        "蛾！\n"
      )
      expect(tokens).to contain_exactly_in_order(
        [Token::DEBUG], [Token::BANG]
      )
    end
  end
end
