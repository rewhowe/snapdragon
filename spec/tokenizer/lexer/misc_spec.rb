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

    it 'tokenizes logarithm' do
      mock_reader(
        "5を 底と する 125の 対数\n"
      )
      expect(tokens).to contain_exactly_in_order(
        [Token::PARAMETER, '5', Token::VAL_NUM],
        [Token::PARAMETER, '125', Token::VAL_NUM],
        [Token::LOGARITHM],
      )
    end

    it 'tokenizes logarithm with properties and variables' do
      mock_reader(
        "ホゲは 「あいうえお」\n" \
        "フガは 125\n" \
        "ホゲの 長さを 底と する フガの 対数\n"
      )
      expect(tokens).to contain_exactly_in_order(
        [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE],
        [Token::RVALUE, '「あいうえお」', Token::VAL_STR],
        [Token::ASSIGNMENT, 'フガ', Token::VARIABLE],
        [Token::RVALUE, '125', Token::VAL_NUM],
        [Token::POSSESSIVE, 'ホゲ', Token::VARIABLE],
        [Token::PARAMETER, '長さ', Token::PROP_LEN],
        [Token::PARAMETER, 'フガ', Token::VARIABLE],
        [Token::LOGARITHM],
      )
    end
  end
end
