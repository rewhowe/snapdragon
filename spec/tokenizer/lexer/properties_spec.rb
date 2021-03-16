require './src/token'
require './src/tokenizer/built_ins'
require './src/tokenizer/lexer'
require './spec/contexts/lexer'

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
        [Token::POSSESSIVE, '「ほげ」', Token::VAL_STR],
        [Token::PROPERTY, '長さ', Token::PROP_LEN],
      )
    end

    it 'tokenizes all length property aliases' do
      %w[
        長さ
        ながさ
        大きさ
        おおきさ
        数
        かず
        人数
        個数
        件数
        匹数
        文字数
      ].each do |property|
        mock_reader(
          "あれは 配列\n" \
          "それは あれの #{property}\n"
        )

        expect(tokens).to contain_exactly(
          [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
          [Token::ASSIGNMENT, 'それ', Token::VAR_SORE],
          [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
          [Token::PROPERTY, property, Token::PROP_LEN],
        )
      end
    end

    it 'tokenizes assignment to/from different types of properties' do
      complex_properties_and_tokens.each do |property, expected_token|
        mock_reader(
          "ホゲは 配列\n" \
          "キー名は 「フガ」\n" \
          "ホゲの #{property}は 1\n" \
          "ふがは ホゲの #{property}\n"
        )
        expect(tokens).to contain_exactly(
          [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
          [Token::ASSIGNMENT, 'キー名', Token::VARIABLE], [Token::RVALUE, '「フガ」', Token::VAL_STR],
          [Token::POSSESSIVE, 'ホゲ', Token::VARIABLE],
          [Token::ASSIGNMENT, *expected_token[1, 2]],
          [Token::RVALUE, '1', Token::VAL_NUM],
          [Token::ASSIGNMENT, 'ふが', Token::VARIABLE],
          [Token::POSSESSIVE, 'ホゲ', Token::VARIABLE], expected_token,
        )
      end
    end

    it 'tokenizes assignment from different types of read-only properties' do
      basic_properties_and_tokens.each do |property, expected_token|
        mock_reader(
          "ホゲは 配列\n" \
          "ふがは ホゲの #{property}\n"
        )
        expect(tokens).to contain_exactly(
          [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
          [Token::ASSIGNMENT, 'ふが', Token::VARIABLE],
          [Token::POSSESSIVE, 'ホゲ', Token::VARIABLE], expected_token,
        )
      end
    end

    it 'tokenizes assignment with similarly-named variables' do
      mock_reader(
        "ほげは 配列\n" \
        "ほげのは 1\n" \
        "ふがは ほげの 長さ\n"
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ほげ', Token::VARIABLE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::ASSIGNMENT, 'ほげの', Token::VARIABLE], [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::ASSIGNMENT, 'ふが', Token::VARIABLE],
        [Token::POSSESSIVE, 'ほげ', Token::VARIABLE], [Token::PROPERTY, '長さ', Token::PROP_LEN],
      )
    end

    it 'tokenizes if statements with possessive-like variables' do
      mock_reader(
        "それのは 1\n" \
        "「ほげ」のは 1\n" \
        "もし それのが 「ほげ」の ならば\n"
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'それの', Token::VARIABLE], [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::ASSIGNMENT, '「ほげ」の', Token::VARIABLE], [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::IF],
        [Token::COMP_EQ],
        [Token::RVALUE, 'それの', Token::VARIABLE],
        [Token::RVALUE, '「ほげ」の', Token::VARIABLE],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes boolean-cast properties' do
      mock_reader(
        "参加者達は 配列\n" \
        "パーティーに来る人数は 参加者達の 数？\n"
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '参加者達', Token::VARIABLE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::ASSIGNMENT, 'パーティーに来る人数', Token::VARIABLE],
        [Token::POSSESSIVE, '参加者達', Token::VARIABLE],
        [Token::PROPERTY, '数', Token::PROP_LEN],
        [Token::QUESTION],
      )
    end

    it 'tokenizes properties in array assignment' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さ、あれの 1つ目\n"
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE], [Token::PROPERTY, '長さ', Token::PROP_LEN], [Token::COMMA],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE], [Token::PROPERTY, '1', Token::KEY_INDEX],
        [Token::ARRAY_CLOSE],
      )
    end

    it 'tokenizes properties in array assignment with boolean cast' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さ？、あれの 1つ目？\n"
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE], [Token::PROPERTY, '長さ', Token::PROP_LEN],
        [Token::QUESTION], [Token::COMMA],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE], [Token::PROPERTY, '1', Token::KEY_INDEX],
        [Token::QUESTION],
        [Token::ARRAY_CLOSE],
      )
    end

    it 'tokenizes properties in function calls' do
      properties_and_tokens(Token::PARAMETER).each do |property, expected_token|
        mock_reader(
          "ホゲは 配列\n" \
          "キー名は 「フガ」\n" \
          "ホゲの #{property}に 1を 足す\n"
        )

        expect(tokens).to contain_exactly(
          [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
          [Token::ASSIGNMENT, 'キー名', Token::VARIABLE], [Token::RVALUE, '「フガ」', Token::VAL_STR],
          [Token::POSSESSIVE, 'ホゲ', Token::VARIABLE], expected_token,
          [Token::PARAMETER, '1', Token::VAL_NUM],
          [Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, Token::FUNC_BUILT_IN],
        )
      end
    end

    it 'tokenizes properties in function calls with implicit それ' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さで 割る\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::PARAMETER, 'それ', Token::VAR_SORE],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
        [Token::PARAMETER, '長さ', Token::PROP_LEN],
        [Token::FUNCTION_CALL, Tokenizer::BuiltIns::DIVIDE, Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes properties in simple if statements' do
      properties_and_tokens.each do |property, expected_token|
        mock_reader(
          "ホゲは 配列\n" \
          "キー名は 「フガ」\n" \
          "もし ホゲの #{property}？ ならば\n" \
          "　・・・\n"
        )

        expect(tokens).to contain_exactly(
          [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
          [Token::ASSIGNMENT, 'キー名', Token::VARIABLE], [Token::RVALUE, '「フガ」', Token::VAL_STR],
          [Token::IF],
          [Token::COMP_EQ],
          [Token::RVALUE, '真', Token::VAL_TRUE],
          [Token::POSSESSIVE, 'ホゲ', Token::VARIABLE], expected_token,
          [Token::QUESTION],
          [Token::SCOPE_BEGIN],
          [Token::NO_OP],
          [Token::SCOPE_CLOSE],
        )
      end
    end

    it 'tokenizes properties in if statements (comp 1 and comp 2)' do
      properties_and_tokens.each do |property, expected_token|
        mock_reader(
          "ホゲは 配列\n" \
          "キー名は 「フガ」\n" \
          "もし ホゲの #{property}が ホゲの #{property}と 等しければ\n" \
          "　・・・\n"
        )

        expect(tokens).to contain_exactly(
          [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
          [Token::ASSIGNMENT, 'キー名', Token::VARIABLE], [Token::RVALUE, '「フガ」', Token::VAL_STR],
          [Token::IF],
          [Token::COMP_EQ],
          [Token::POSSESSIVE, 'ホゲ', Token::VARIABLE], expected_token,
          [Token::POSSESSIVE, 'ホゲ', Token::VARIABLE], expected_token,
          [Token::SCOPE_BEGIN],
          [Token::NO_OP],
          [Token::SCOPE_CLOSE],
        )
      end
    end

    it 'tokenizes properties in functional if statements' do
      properties_and_tokens(Token::PARAMETER).each do |property, expected_token|
        mock_reader(
          "ホゲは 配列\n" \
          "キー名は 「フガ」\n" \
          "もし ホゲの #{property}に 1を 足した？ ならば\n"
        )

        expect(tokens).to contain_exactly(
          [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
          [Token::ASSIGNMENT, 'キー名', Token::VARIABLE], [Token::RVALUE, '「フガ」', Token::VAL_STR],
          [Token::IF],
          [Token::COMP_EQ],
          [Token::POSSESSIVE, 'ホゲ', Token::VARIABLE], expected_token,
          [Token::PARAMETER, '1', Token::VAL_NUM],
          [Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, Token::FUNC_BUILT_IN],
          [Token::SCOPE_BEGIN],
          [Token::SCOPE_CLOSE],
        )
      end
    end

    it 'tokenizes properties in loops' do
      properties_and_tokens(Token::PARAMETER).each do |property, expected_token|
        mock_reader(
          "ホゲは 配列\n" \
          "キー名は 「フガ」\n" \
          "ホゲの #{property}から ホゲの #{property}まで 繰り返す\n"
        )

        expect(tokens).to contain_exactly(
          [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
          [Token::ASSIGNMENT, 'キー名', Token::VARIABLE], [Token::RVALUE, '「フガ」', Token::VAL_STR],
          [Token::POSSESSIVE, 'ホゲ', Token::VARIABLE], expected_token,
          [Token::POSSESSIVE, 'ホゲ', Token::VARIABLE], expected_token,
          [Token::LOOP],
          [Token::SCOPE_BEGIN],
          [Token::SCOPE_CLOSE],
        )
      end
    end

    it 'tokenizes properties in loop iterators' do
      complex_properties_and_tokens(Token::PARAMETER).each do |property, expected_token|
        mock_reader(
          "ホゲは 連想配列\n" \
          "キー名は 「フガ」\n" \
          "ホゲの #{property}に 対して 繰り返す\n"
        )

        expect(tokens).to contain_exactly(
          [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE], [Token::RVALUE, '連想配列', Token::VAL_ARRAY],
          [Token::ASSIGNMENT, 'キー名', Token::VARIABLE], [Token::RVALUE, '「フガ」', Token::VAL_STR],
          [Token::POSSESSIVE, 'ホゲ', Token::VARIABLE], expected_token,
          [Token::LOOP_ITERATOR],
          [Token::LOOP],
          [Token::SCOPE_BEGIN],
          [Token::SCOPE_CLOSE],
        )
      end
    end

    it 'tokenizes properties in return' do
      properties_and_tokens(Token::PARAMETER).each do |property, expected_token|
        mock_reader(
          "ホゲは 配列\n" \
          "キー名は 「フガ」\n" \
          "ホゲの #{property}を 返す\n"
        )

        expect(tokens).to contain_exactly(
          [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
          [Token::ASSIGNMENT, 'キー名', Token::VARIABLE], [Token::RVALUE, '「フガ」', Token::VAL_STR],
          [Token::POSSESSIVE, 'ホゲ', Token::VARIABLE], expected_token,
          [Token::RETURN],
        )
      end
    end

    # Strange, but valid.
    it 'tokenizes assignment of a property to its owner' do
      mock_reader(
        "ホゲは 配列\n" \
        "ホゲは ホゲの 長さ\n"
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE],
        [Token::POSSESSIVE, 'ホゲ', Token::VARIABLE],
        [Token::PROPERTY, '長さ', Token::PROP_LEN],
      )
    end

    private

    # TODO: split into read-only and read-write, then have iterable separate
    def properties_and_tokens(type = Token::PROPERTY)
      basic_properties_and_tokens(type).merge complex_properties_and_tokens(type)
    end

    ##
    # Non-iterable or non-assignable.
    def basic_properties_and_tokens(type = Token::PROPERTY)
      {
        '長さ' => [type, '長さ', Token::PROP_LEN],
      }
    end

    ##
    # Not restricted to any type at runtime.
    # rubocop:disable Layout/SpaceAroundOperators
    def complex_properties_and_tokens(type = Token::PROPERTY)
      {
        '1つ目'      => [type, '1', Token::KEY_INDEX],
        '「キー名」' => [type, '「キー名」', Token::KEY_NAME],
        'キー名'     => [type, 'キー名', Token::KEY_VAR],
        'それ'       => [type, 'それ', Token::KEY_SORE],
        'あれ'       => [type, 'あれ', Token::KEY_ARE],
      }
    end
    # rubocop:enable Layout/SpaceAroundOperators
  end
end
