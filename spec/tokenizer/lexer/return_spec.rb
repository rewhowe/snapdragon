require './src/token'
require './src/tokenizer/lexer'
require './spec/contexts/lexer'

include Tokenizer

RSpec.describe Lexer, 'return' do
  include_context 'lexer'

  describe '#next_token' do
    it 'tokenizes a normal return' do
      %w[
        返る
        戻る
      ].each do |keyword|
        mock_reader(
          "#{keyword}\n"
        )

        expect(tokens).to contain_exactly_in_order(
          [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN]
        )
      end
    end

    it 'tokenizes an explicit return' do
      {
        'を' => '返す',
        'と' => 'なる',
      }.each do |particle, keyword|
        mock_reader(
          "1#{particle} #{keyword}\n"
        )

        expect(tokens).to contain_exactly_in_order(
          [Token::PARAMETER, '1', Token::VAL_NUM],
          [Token::RETURN]
        )
      end
    end

    it 'tokenizes an implicit return' do
      mock_reader(
        "返す\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::PARAMETER, 'それ', Token::VAR_SORE],
        [Token::RETURN]
      )
    end

    it 'tokenizes a return inside a function' do
      mock_reader(
        "何かを 復唱するとは\n" \
        "　何かを 返す\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::PARAMETER, '何か', Token::VARIABLE],
        [Token::FUNCTION_DEF, '復唱する'],
        [Token::SCOPE_BEGIN],
        [Token::PARAMETER, '何か', Token::VARIABLE],
        [Token::RETURN],
        [Token::SCOPE_CLOSE]
      )
    end

    it 'appends a return to a function with no return' do
      mock_reader(
        "直ぐに リターンするとは\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly_in_order(
        [Token::PARAMETER, '直ぐ', Token::VARIABLE],
        [Token::FUNCTION_DEF, 'リターンする'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::PARAMETER, '無', Token::VAL_NULL],
        [Token::RETURN],
        [Token::SCOPE_CLOSE]
      )
    end
  end
end
