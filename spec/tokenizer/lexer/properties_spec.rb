require './src/tokenizer/lexer.rb'
require './src/tokenizer/token.rb'

require './spec/contexts/lexer.rb'

include Tokenizer

RSpec.describe Lexer, 'properties' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'tokenizes assignment with string length' do
      mock_reader(
        "文字数は 「ほげ」の 長さ\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '文字数', Token::VARIABLE],
        [Token::PROPERTY, '「ほげ」', Token::VAR_STR],
        [Token::ATTRIBUTE, '長さ', Token::ATTR_LEN],
      )
    end

    it 'tokenizes all length attribute aliases' do
      %[
        長さ
        ながさ
        大きさ
        おおきさ
        数
        かず
      ].each do |attribute|
        mock_reader(
          "あれは 配列\n" \
          "それは あれの #{attribute}\n"
        )

        expect(tokens).to contain_exactly(
          [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::VARIABLE, '配列', Token::VAR_ARRAY],
          [Token::ASSIGNMENT, 'それ', Token::VAR_SORE],
          [Token::PROPERTY, 'あれ', Token::VAR_ARE],
          [Token::ATTRIBUTE, attribute, Token::ATTR_LEN],
        )
      end
    end

    it 'tokenizes properties in function calls' do
      mock_reader(
        "あれは 配列\n" \
        "「ほげ」の 長さに あれの 長さを 足す\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::VARIABLE, '配列', Token::VAR_ARRAY],
        [Token::PROPERTY, '「ほげ」', Token::VAR_STR],
        [Token::PARAMETER, '長さ', Token::ATTR_LEN],
        [Token::PROPERTY, 'あれ', Token::VAR_ARE],
        [Token::PARAMETER, '長さ', Token::ATTR_LEN],
        [Token::FUNCTION_CALL, '足す', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes properties in function calls with implicit それ' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さで 割る\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::VARIABLE, '配列', Token::VAR_ARRAY],
        [Token::VARIABLE, 'それ', Token::VAR_SORE],
        [Token::PROPERTY, 'あれ', Token::VAR_ARE],
        [Token::PARAMETER, '長さ', Token::ATTR_LEN],
        [Token::FUNCTION_CALL, '割る', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes properties in simple if statements' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さ？ ならば\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::VARIABLE, '配列', Token::VAR_ARRAY],
        [Token::IF, 'もし'],
        [Token::COMP_EQ],
        [Token::VARIABLE, '真', Token::VAR_BOOL],
        [Token::PROPERTY, 'あれ', Token::VAR_ARE],
        [Token::PARAMETER, '長さ', Token::ATTR_LEN],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes properties in comparison if statements' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さが あれの 長さと 等しければ\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::VARIABLE, '配列', Token::VAR_ARRAY],
        [Token::IF, 'もし'],
        [Token::COMP_EQ],
        [Token::PROPERTY, 'あれ', Token::VAR_ARE],
        [Token::PARAMETER, '長さ', Token::ATTR_LEN],
        [Token::PROPERTY, 'あれ', Token::VAR_ARE],
        [Token::PARAMETER, '長さ', Token::ATTR_LEN],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes properties in functional if statements' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さを 足した？ ならば\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::VARIABLE, '配列', Token::VAR_ARRAY],
        [Token::IF, 'もし'],
        [Token::COMP_EQ],
        [Token::VARIABLE, '真', Token::VAR_BOOL],
        [Token::PROPERTY, 'あれ', Token::VAR_ARE],
        [Token::PARAMETER, '長さ', Token::ATTR_LEN],
        [Token::FUNCTION_CALL, '足す', Token::FUNC_BUILT_IN],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes properties in loops' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さから あれの 長さまで 繰り返す\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::VARIABLE, '配列', Token::VAR_ARRAY],
        [Token::PROPERTY, 'あれ', Token::VAR_ARE],
        [Token::PARAMETER, '長さ', Token::ATTR_LEN],
        [Token::PROPERTY, 'あれ', Token::VAR_ARE],
        [Token::PARAMETER, '長さ', Token::ATTR_LEN],
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    # TODO: (v1.1.0)
    # it 'tokenizes key variables in loops' do
    #   mock_reader(
    #     "あれは 連想配列\n" \
    #     "あれの 「ホゲ」は 「フガ」\n" \
    #     "あれの 「ホゲ」に 対して 繰り返す\n"
    #   )

    #   expect(tokens).to contain_exactly(
    #     [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::VARIABLE, '連想配列', Token::VAR_ARRAY],
    #     [Token::PROPERTY, 'あれ', Token::VAR_ARE],
    #     [Token::ASSIGNMENT, '「ホゲ」', Token::KEY_VARIABLE],
    #     [Token::VARIABLE, '「フガ」', Token::VAR_STR],
    #     [Token::PROPERTY, 'あれ', Token::VAR_ARE],
    #     [Token::PARAMETER, '「ホゲ」', Token::KEY_VARIABLE],
    #     [Token::PROPERTY, 'あれ', Token::VAR_ARE],
    #     [Token::LOOP_ITERATOR],
    #     [Token::LOOP],
    #     [Token::SCOPE_BEGIN],
    #     [Token::SCOPE_CLOSE],
    #   )
    # end

    it 'tokenizes properties in return' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さを 返す\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::VARIABLE, '配列', Token::VAR_ARRAY],
        [Token::PROPERTY, 'あれ', Token::VAR_ARE],
        [Token::PARAMETER, '長さ', Token::ATTR_LEN],
        [Token::RETURN],
      )
    end
  end
end
