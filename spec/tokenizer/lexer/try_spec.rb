require './src/token'
require './src/tokenizer/built_ins'
require './src/tokenizer/lexer'
require './spec/contexts/lexer'

include Tokenizer

RSpec.describe Lexer, 'try' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'tokenizes a try block' do
      mock_reader(
        "試す\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::TRY],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'can tokenize break inside try' do
      mock_reader(
        "繰り返す\n" \
        "　試す\n" \
        "　　終わり\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::LOOP], [Token::SCOPE_BEGIN],
        [Token::TRY], [Token::SCOPE_BEGIN],
        [Token::BREAK],
        [Token::SCOPE_CLOSE],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'can tokenize next inside try' do
      mock_reader(
        "繰り返す\n" \
        "　試す\n" \
        "　　次\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::LOOP], [Token::SCOPE_BEGIN],
        [Token::TRY], [Token::SCOPE_BEGIN],
        [Token::NEXT],
        [Token::SCOPE_CLOSE],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'can tokenize function definitions inside try' do
      mock_reader(
        "試す\n" \
        "　ほげるとは\n" \
        "　　・・・\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::TRY], [Token::SCOPE_BEGIN],
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
        [Token::SCOPE_CLOSE],
        [Token::SCOPE_CLOSE],
      )
    end
  end
end
