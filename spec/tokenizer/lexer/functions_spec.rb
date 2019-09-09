require './src/tokenizer/lexer.rb'
require './src/tokenizer/token.rb'
require './spec/contexts/lexer.rb'

include Tokenizer

RSpec.describe Lexer, 'functions' do
  include_context 'lexer'

  describe '#next_token' do
    it 'tokenizes function declarations' do
      mock_reader(
        "ほげるとは\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes nested function declarations' do
      mock_reader(
        "ほげるとは\n" \
        "　ふがるとは\n" \
        "　　・・・\n"
      )

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::FUNCTION_DEF, 'ふがる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE], [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes function calls' do
      mock_reader(
        "ほげるとは\n" \
        "　・・・\n" \
        "ほげる\n"
      )

      expect(tokens).to include(
        [Token::FUNCTION_CALL, 'ほげる']
      )
    end

    it 'tokenizes calls to parent scope functions' do
      mock_reader(
        "ほげるとは\n" \
        "　・・・\n" \
        "ふがるとは\n" \
        "　ほげる\n"
      )

      expect(tokens).to include(
        [Token::FUNCTION_CALL, 'ほげる']
      )
    end

    it 'tokenizes function calls to self' do
      mock_reader(
        "ほげるとは\n" \
        "　ほげる\n"
      )

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::FUNCTION_CALL, 'ほげる'],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes function calls with parameters' do
      mock_reader(
        "トモダチと ドコカへ ナニカを ノリモノで 一緒に持っていくとは\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, 'トモダチ'],
        [Token::PARAMETER, 'ドコカ'],
        [Token::PARAMETER, 'ナニカ'],
        [Token::PARAMETER, 'ノリモノ'],
        [Token::FUNCTION_DEF, '一緒に持っていく'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes conjugated function calls' do
      mock_reader(
        "タベモノを 食べるとは\n" \
        "　・・・\n" \
        "「朝ご飯」を 食べた\n" \
        "「昼ご飯」を 食べて\n" \
      )

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, 'タベモノ'],
        [Token::FUNCTION_DEF, '食べる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, '「朝ご飯」'],
        [Token::FUNCTION_CALL, '食べる'],
        [Token::PARAMETER, '「昼ご飯」'],
        [Token::FUNCTION_CALL, '食べる'],
      )
    end

    it 'tokenizes function calls with questions' do
      mock_reader(
        "タベモノを 食べるとは\n" \
        "　・・・\n" \
        "「野菜」を 食べた？\n"
      )

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, 'タベモノ'],
        [Token::FUNCTION_DEF, '食べる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, '「野菜」'],
        [Token::FUNCTION_CALL, '食べる'],
        [Token::QUESTION],
      )
    end

    it 'tokenizes function calls with bangs' do
      # TODO
      mock_reader(
        "タベモノを 食べるとは\n" \
        "　・・・\n" \
        "「野菜」を 食べて！\n"
      )

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, 'タベモノ'],
        [Token::FUNCTION_DEF, '食べる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, '「野菜」'],
        [Token::FUNCTION_CALL, '食べる'],
        [Token::BANG],
      )
    end

    it 'tokenizes function calls with bang-questions' do
      # TODO: not yet implemented
      # mock_reader(
      #   "タベモノを 食べるとは\n" \
      #   "　・・・\n" \
      #   "「本当に野菜」を 食べた！？\n"
      # )

      # expect(tokens).to contain_exactly(
      #   [Token::PARAMETER, 'タベモノ'],
      #   [Token::FUNCTION_DEF, '食べる'],
      #   [Token::SCOPE_BEGIN],
      #   [Token::NO_OP],
      #   [Token::SCOPE_CLOSE],
      #   [Token::PARAMETER, '「本当に野菜」'],
      #   [Token::FUNCTION_CALL, '食べる'],
      #   [Token::BANG],
      #   [Token::QUESTION],
      # )
    end

    it 'tokenizes function calls regardless of parameter order' do
      mock_reader(
        "Ａと Ｂを ほげるとは\n" \
        "　・・・\n" \
        "「Ｂ」と 「Ａ」を ほげる\n"
      )

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, 'Ａ'],
        [Token::PARAMETER, 'Ｂ'],
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, '「Ａ」'],
        [Token::PARAMETER, '「Ｂ」'],
        [Token::FUNCTION_CALL, 'ほげる'],
      )
    end

    it 'tokenizes built-in functions' do
      mock_reader(
        "「言葉」を 言う\n" \
        "「メッセージ」を ログする\n" \
        "「メッセージ」を 表示する\n" \
        "「エラー」を 投げる\n" \
        "配列に 「追加対象」を 追加する\n" \
        "配列に 配列を 連結する\n" \
        "ほげは 1、2、2、2\n" \
        "ほげから 2を 抜く\n" \
        "ほげから 2を 全部抜く\n" \
        "1に 1を 足す\n" \
        "1から 1を 引く\n" \
        "2に 3を 掛ける\n" \
        "10を 2で 割る\n" \
        "7を 3で 割った余りを求める\n"
      )

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '「言葉」'], [Token::FUNCTION_CALL, '言う'],
        [Token::PARAMETER, '「メッセージ」'], [Token::FUNCTION_CALL, 'ログする'],
        [Token::PARAMETER, '「メッセージ」'], [Token::FUNCTION_CALL, '表示する'],
        [Token::PARAMETER, '「エラー」'], [Token::FUNCTION_CALL, '投げる'],
        [Token::PARAMETER, '配列'], [Token::PARAMETER, '「追加対象」'], [Token::FUNCTION_CALL, '追加する'],
        [Token::PARAMETER, '配列'], [Token::PARAMETER, '配列'], [Token::FUNCTION_CALL, '連結する'],
        [Token::ASSIGNMENT, 'ほげ'],
        [Token::ARRAY_BEGIN],
        [Token::VARIABLE, '1'], [Token::COMMA],
        [Token::VARIABLE, '2'], [Token::COMMA],
        [Token::VARIABLE, '2'], [Token::COMMA],
        [Token::VARIABLE, '2'],
        [Token::ARRAY_CLOSE],
        [Token::PARAMETER, 'ほげ'], [Token::PARAMETER, '2'], [Token::FUNCTION_CALL, '抜く'],
        [Token::PARAMETER, 'ほげ'], [Token::PARAMETER, '2'], [Token::FUNCTION_CALL, '全部抜く'],
        [Token::PARAMETER, '1'], [Token::PARAMETER, '1'], [Token::FUNCTION_CALL, '足す'],
        [Token::PARAMETER, '1'], [Token::PARAMETER, '1'], [Token::FUNCTION_CALL, '引く'],
        [Token::PARAMETER, '2'], [Token::PARAMETER, '3'], [Token::FUNCTION_CALL, '掛ける'],
        [Token::PARAMETER, '10'], [Token::PARAMETER, '2'], [Token::FUNCTION_CALL, '割る'],
        [Token::PARAMETER, '7'], [Token::PARAMETER, '3'], [Token::FUNCTION_CALL, '割った余りを求める'],
      )
    end

    it 'tokenizes built-in functions with alternate signatures' do
      mock_reader(
        "「名前」を 言う\n" \
        "数値は 0\n" \
        "1を 足す\n" \
        "10を 引く\n" \
        "100を 掛ける\n" \
        "1000で 割る\n" \
        "0.2で 割った余りを求める\n"
      )

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, '「名前」'], [Token::FUNCTION_CALL, '言う'],
        [Token::ASSIGNMENT, '数値'], [Token::VARIABLE, '0'],
        [Token::PARAMETER, '1'], [Token::FUNCTION_CALL, '足す'],
        [Token::PARAMETER, '10'], [Token::FUNCTION_CALL, '引く'],
        [Token::PARAMETER, '100'], [Token::FUNCTION_CALL, '掛ける'],
        [Token::PARAMETER, '1000'], [Token::FUNCTION_CALL, '割る'],
        [Token::PARAMETER, '0.2'], [Token::FUNCTION_CALL, '割った余りを求める'],
      )
    end
  end
end
