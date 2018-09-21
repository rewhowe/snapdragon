require './src/tokenizer/lexer.rb'
require './src/tokenizer/token.rb'
require './spec/contexts/lexer.rb'

include Tokenizer

RSpec.describe Lexer, 'functions' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'tokenizes function declarations' do
      write_test_file [
        'ほげるとは',
        '　・・・',
      ]

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes nested function declarations' do
      write_test_file [
        'ほげるとは',
        '　ふがるとは',
        '　　・・・'
      ]

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::FUNCTION_DEF, 'ふがる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes function calls' do
      write_test_file [
        'ほげるとは',
        '　・・・',
        'ほげる',
      ]

      expect(tokens).to include(
        [Token::FUNCTION_CALL, 'ほげる']
      )
    end

    it 'tokenizes calls to parent scope functions' do
      write_test_file [
        'ほげるとは',
        '　・・・',
        'ふがるとは',
        '　ほげる',
      ]

      expect(tokens).to include(
        [Token::FUNCTION_CALL, 'ほげる']
      )
    end

    it 'tokenizes function calls to self' do
      write_test_file [
        'ほげるとは',
        '　ほげる',
      ]

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::FUNCTION_CALL, 'ほげる'],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes function calls with parameters' do
      write_test_file [
        'トモダチと ドコカへ ナニカを ノリモノで 一緒に持っていくとは',
        '　・・・',
      ]

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
      write_test_file [
        'タベモノを 食べるとは',
        '　・・・',
        '「朝ご飯」を 食べた',
        '「昼ご飯」を 食べて',
      ]

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
      # TODO
    end

    it 'tokenizes function calls with bangs' do
      # TODO
    end

    it 'tokenizes function calls with bang-questions' do
      # TODO
    end

    it 'tokenizes function calls regardless of parameter order' do
      write_test_file [
        'Ａと Ｂを ほげるとは',
        '　・・・',
        '「Ｂ」と 「Ａ」を ほげる',
      ]

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
      write_test_file [
        '「言葉」を 言う',
        '「メッセージ」を ログする',
        '「メッセージ」を 表示する',
        '「エラー」を 投げる',
        '配列に 「追加対象」を 追加する',
        '配列に 配列を 連結する',
        '',
        'ほげは 1、2、2、2',
        'ほげから 2を 抜く',
        'ほげから 2を 全部抜く',
        '',
        '1に 1を 足す',
        '1から 1を 引く',
        '2に 3を 掛ける',
        '10を 2で 割る',
        '7を 3で 割った余りを求める',
      ]

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
      write_test_file [
        '「名前」を 言う',
        '数値は 0',
        '1を 足す',
        '10を 引く',
        '100を 掛ける',
        '1000で 割る',
        '0.2で 割った余りを求める',
      ]

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
