require './src/lexer.rb'
require './src/token.rb'
require './spec/contexts/lexer.rb'

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'

  describe '#tokenize' do
    after :all do
      expect { Lexer.new.tokenize(@test_file.path) } .to raise_error StandardError
    end

    it 'raises an error on unexpected EOL' do
      write_test_file [
        '変数は 1、'
      ]
    end

    it 'raises an error when missing tokens' do
      write_test_file [
        '変数は',
      ]
    end

    it 'raises an error when too much indent' do
      write_test_file [
        'インデントしすぎるとは',
        '　　行頭の空白は 「多い」',
      ]
    end

    it 'raises an error for unclosed strings in variable declarations' do
      write_test_file [
        '変数はは 「もじれつ',
      ]
    end

    it 'raises an error for unclosed strings parameters' do
      write_test_file [
        'モジレツを 読むとは',
        '　・・・',
        '「もじれつを 読む',
      ]
    end

    it 'raises an error for trailing characters after bang' do
      write_test_file [
        'ほげるとは',
        '　・・・',
        'ほげる！ あと何かをする',
      ]
    end

    it 'raises an error on trailing characters in array declaration' do
      write_test_file [
        '変数は 「えっと」、「なんだっけ？」 と言った',
      ]
    end

    it 'raises an error when assigning to value' do
      write_test_file [
        '1は 2'
      ]
    end

    it 'raises an error on trailing characters after funtion def' do
      write_test_file [
        'ほげるとは 何かな？',
      ]
    end

    it 'raises an error when missing parameters in function call' do
      write_test_file [
        'タベモノを 食べるとは',
        '　・・・',
        '食べる',
      ]
    end

    it 'raises an error when calling function nonexistent in scope' do
      write_test_file [
        'ほげるとは',
        '　ふがるとは',
        '　　・・・',
        'ふがる',
      ]
    end

    it 'raises an error when declaring non-verb-like function' do
      write_test_file [
        'ポテトとは',
        '　これは 「食べ物」',
      ]
    end

    it 'raises an error when calling function with wrong particles' do
      write_test_file [
        'タベモノを 食べるとは',
        '　・・・',
        '「ポテト」に 食べる',
      ]
    end

    it 'raises an error when declaring function inside if statement' do
      # TODO: test
      fail
      write_test_file [
        'もし 引数を ほげるとは',
      ]
    end

    it 'raises an error for unclosed if statements' do
      # TODO: test
      fail
      write_test_file [
        'もし 「ほげ」と 言う？',
      ]
    end

    it 'raises an error for comments in if statements' do
      # TODO: test
      write_test_file [
        'もし 「ほげ」と 言う（コメント',
      ]
    end
  end
end
