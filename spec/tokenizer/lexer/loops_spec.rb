require './src/tokenizer/lexer.rb'
require './src/tokenizer/token.rb'
require './spec/contexts/lexer.rb'

include Tokenizer

RSpec.describe Lexer, 'loops' do
  include_context 'lexer'

  describe '#next_token' do
    it 'tokenizes basic loops' do
      mock_reader(
        "繰り返す\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly(
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes loops over ranges' do
      mock_reader(
        "1から 100まで 繰り返す\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '1'],
        [Token::PARAMETER, '100'],
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes loops over collections' do
      mock_reader(
        "友達は 「ジャック」、「ウイ」、「チャールズ」\n" \
        "友達に 対して 繰り返す\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '友達'],
        [Token::ARRAY_BEGIN],
        [Token::VARIABLE, '「ジャック」'], [Token::COMMA],
        [Token::VARIABLE, '「ウイ」'], [Token::COMMA],
        [Token::VARIABLE, '「チャールズ」'],
        [Token::ARRAY_CLOSE],
        [Token::PARAMETER, '友達'],
        [Token::LOOP_ITERATOR],
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end
  end
end
