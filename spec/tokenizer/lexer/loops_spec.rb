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
        [Token::PARAMETER, '1', Token::VAR_NUM],
        [Token::PARAMETER, '100', Token::VAR_NUM],
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
        [Token::ASSIGNMENT, '友達', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::VARIABLE, '「ジャック」', Token::VAR_STR], [Token::COMMA],
        [Token::VARIABLE, '「ウイ」', Token::VAR_STR], [Token::COMMA],
        [Token::VARIABLE, '「チャールズ」', Token::VAR_STR],
        [Token::ARRAY_CLOSE],
        [Token::PARAMETER, '友達', Token::VARIABLE],
        [Token::LOOP_ITERATOR],
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes next keyword in loops' do
      mock_reader(
        "繰り返す\n" \
        "　次\n"
      )

      expect(tokens).to contain_exactly(
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::NEXT],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes break keyword in loops' do
      mock_reader(
        "繰り返す\n" \
        "　終わり\n"
      )

      expect(tokens).to contain_exactly(
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::BREAK],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes break and next keywords nested in loops' do
      mock_reader(
        "繰り返す\n" \
        "　もし 1が 1？ ならば\n" \
        "　　次\n" \
        "　違えば\n" \
        "　　終わり\n"
      )

      expect(tokens).to contain_exactly(
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::IF],
        [Token::COMP_EQ],
        [Token::VARIABLE, '1', Token::VAR_NUM],
        [Token::VARIABLE, '1', Token::VAR_NUM],
        [Token::SCOPE_BEGIN],
        [Token::NEXT],
        [Token::SCOPE_CLOSE],
        [Token::ELSE],
        [Token::SCOPE_BEGIN],
        [Token::BREAK],
        [Token::SCOPE_CLOSE],
        [Token::SCOPE_CLOSE],
      )
    end
  end
end
