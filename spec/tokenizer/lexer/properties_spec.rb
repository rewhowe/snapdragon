require './src/token'
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

    it 'tokenizes assignment similarly-named variables' do
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
        "もし それのが 「ほげ」の？ ならば\n"
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
        "人が来るのは 参加者達の 数？\n"
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, '参加者達', Token::VARIABLE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::ASSIGNMENT, '人が来るの', Token::VARIABLE],
        [Token::POSSESSIVE, '参加者達', Token::VARIABLE],
        [Token::PROPERTY, '数', Token::PROP_LEN],
        [Token::QUESTION],
      )
    end

    it 'tokenizes properties in array assignment' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さ、あれの 長さ\n"
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE], [Token::PROPERTY, '長さ', Token::PROP_LEN], [Token::COMMA],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE], [Token::PROPERTY, '長さ', Token::PROP_LEN],
        [Token::ARRAY_CLOSE],
      )
    end

    it 'tokenizes properties in array assignment with boolean cast' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さ？、あれの 長さ？\n"
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::ASSIGNMENT, 'ホゲ', Token::VARIABLE],
        [Token::ARRAY_BEGIN],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE], [Token::PROPERTY, '長さ', Token::PROP_LEN],
        [Token::QUESTION], [Token::COMMA],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE], [Token::PROPERTY, '長さ', Token::PROP_LEN],
        [Token::QUESTION],
        [Token::ARRAY_CLOSE],
      )
    end

    it 'tokenizes properties in function calls' do
      mock_reader(
        "あれは 配列\n" \
        "「ほげ」の 長さに あれの 長さを 足す\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::POSSESSIVE, '「ほげ」', Token::VAL_STR],
        [Token::PARAMETER, '長さ', Token::PROP_LEN],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
        [Token::PARAMETER, '長さ', Token::PROP_LEN],
        [Token::FUNCTION_CALL, '足す', Token::FUNC_BUILT_IN],
      )
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
        [Token::FUNCTION_CALL, '割る', Token::FUNC_BUILT_IN],
      )
    end

    it 'tokenizes properties in simple if statements' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さ？ ならば\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::IF],
        [Token::COMP_EQ],
        [Token::RVALUE, '真', Token::VAL_TRUE],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
        [Token::PROPERTY, '長さ', Token::PROP_LEN],
        [Token::QUESTION],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes properties in simple comparison if statements (comp 1)' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さが 0? ならば\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::IF],
        [Token::COMP_EQ],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
        [Token::PROPERTY, '長さ', Token::PROP_LEN],
        [Token::RVALUE, '0', Token::VAL_NUM],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes properties in simple comparison if statements (comp 2)' do
      mock_reader(
        "あれは 配列\n" \
        "もし 0が あれの 長さ? ならば\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::IF],
        [Token::COMP_EQ],
        [Token::RVALUE, '0', Token::VAL_NUM],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
        [Token::PROPERTY, '長さ', Token::PROP_LEN],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes properties in equality if statements' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さが あれの 長さと 等しければ\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::IF],
        [Token::COMP_EQ],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
        [Token::PROPERTY, '長さ', Token::PROP_LEN],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
        [Token::PROPERTY, '長さ', Token::PROP_LEN],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes properties in functional if statements' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さに あれの 長さを 足した？ ならば\n"
      )

      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::IF],
        [Token::COMP_EQ],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
        [Token::PARAMETER, '長さ', Token::PROP_LEN],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
        [Token::PARAMETER, '長さ', Token::PROP_LEN],
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
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
        [Token::PARAMETER, '長さ', Token::PROP_LEN],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
        [Token::PARAMETER, '長さ', Token::PROP_LEN],
        [Token::LOOP],
        [Token::SCOPE_BEGIN],
        [Token::SCOPE_CLOSE],
      )
    end

    # TODO: (v1.1.0)
    # it 'tokenizes key names in loop iterators' do
    #   mock_reader(
    #     "あれは 連想配列\n" \
    #     "あれの 「ホゲ」は 「フガ」\n" \
    #     "あれの 「ホゲ」に 対して 繰り返す\n"
    #   )

    #   expect(tokens).to contain_exactly(
    #     [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::RVALUE, '連想配列', Token::VAL_ARRAY],
    #     [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
    #     [Token::ASSIGNMENT, '「ホゲ」', Token::KEY_VARIABLE],
    #     [Token::RVALUE, '「フガ」', Token::VAL_STR],
    #     [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
    #     [Token::PARAMETER, '「ホゲ」', Token::KEY_VARIABLE],
    #     [Token::LOOP_ITERATOR],
    #     [Token::LOOP],
    #     [Token::SCOPE_BEGIN],
    #     [Token::SCOPE_CLOSE],
    #   )
    # end

    # TODO: (v1.1.0)
    # it 'tokenizes key names in loop parameters' do
    #   mock_reader(
    #     "あれは 連想配列\n" \
    #     "あれの 「始まり」は 1\n" \
    #     "あれの 「終わり」は 100\n" \
    #     "あれの 「始まり」から あれの「終わり」までに 繰り返す\n"
    #   )

    #   expect(tokens).to contain_exactly(
    #     [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::RVALUE, '連想配列', Token::VAL_ARRAY],
    #     [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
    #     [Token::ASSIGNMENT, '「始まり」', Token::KEY_VARIABLE], [Token::RVALUE, '1', Token::VAL_NUM],
    #     [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
    #     [Token::ASSIGNMENT, '「終わり」', Token::KEY_VARIABLE], [Token::RVALUE, '100', Token::VAL_NUM],
    #     [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
    #     [Token::PARAMETER, '「始まり」', Token::KEY_VARIABLE],
    #     [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
    #     [Token::PARAMETER, '「終わり」', Token::KEY_VARIABLE],
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
        [Token::ASSIGNMENT, 'あれ', Token::VAR_ARE], [Token::RVALUE, '配列', Token::VAL_ARRAY],
        [Token::POSSESSIVE, 'あれ', Token::VAR_ARE],
        [Token::PARAMETER, '長さ', Token::PROP_LEN],
        [Token::RETURN],
      )
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
  end
end
