require './src/lexer.rb'
require './src/token.rb'
require './spec/contexts/lexer.rb'

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
      fail
    end

    it 'tokenizes built-in functions' do
      write_test_file [
        '「言葉」を 言う',
        '「メッセージ」を ログする',
        '「メッセージ」を 表示する',
        '「言葉」を 叫ぶ',
        '配列に 「追加対象」を 追加する',
        '配列に 配列を 連結する',
        '',
        'ほげは 1、2、3',
        'ほげから 3を 抜く',
        '',
        'ほげは 1、2、2',
        'ほげから 2を 全部抜く',
        '1に 1を 足す',
        '1から 1を 引く',
        '2に 3を 掛ける',
        '10を 2で 割る',
        '7を 3で 割った余りを求める',
      ]

      fail
    end

    it 'tokenizes built-in functions with alternate signatures' do
      write_test_file [
        '数値は 0',
        '1を 足す',
        '10を 引く',
        '100を 掛ける',
        '1000で 割る',
        '0.2で 割った余りを求める',
      ]

      fail
    end
  end
end
