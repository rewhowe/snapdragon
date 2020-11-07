require './src/token'
require './src/tokenizer/lexer'
require './spec/contexts/lexer'

include Tokenizer

RSpec.describe Lexer, 'assignment' do
  include_context 'lexer'

  describe '#next_token' do
    it 'tokenizes no-op' do
      mock_reader(
        "・・・\n"
      )
      expect(tokens).to contain_exactly(
        [Token::NO_OP]
      )
    end

    it 'tokenizes debug' do
      mock_reader(
        "蛾\n"
      )
      expect(tokens).to contain_exactly(
        [Token::DEBUG]
      )
    end

    it 'tokenizes debug!' do
      mock_reader(
        "蛾！\n"
      )
      expect(tokens).to contain_exactly(
        [Token::DEBUG], [Token::BANG]
      )
    end
  end
end
