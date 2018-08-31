require './src/tokenizer/lexer.rb'
require './src/tokenizer/token.rb'
require './spec/contexts/lexer.rb'

include Tokenizer

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'

  describe '#tokenize' do
    def expect_error_text(msg)
      expect { Lexer.new.tokenize(@test_file.path) } .to raise_error(/#{msg}/)
    end

    it 'raises an error on unexpected EOL' do
      write_test_file [
        '変数は 1、'
      ]
      expect_error_text 'Unexpected EOL'
    end

    it 'raises an error when missing tokens' do
      write_test_file [
        '変数は',
      ]
      expect_error_text 'Unexpected EOL'
    end

    it 'raises an error when too much indent' do
      write_test_file [
        'インデントしすぎるとは',
        '　　行頭の空白は 「多い」',
      ]
      expect_error_text 'Unexpected indent'
    end

    it 'raises an error for unclosed strings in variable declarations' do
      write_test_file [
        '変数はは 「もじれつ',
      ]
      expect_error_text 'Unclosed string'
    end

    it 'raises an error for unclosed strings parameters' do
      write_test_file [
        'モジレツを 読むとは',
        '　・・・',
        '「もじれつを 読む',
      ]
      expect_error_text 'Unclosed string'
    end

    it 'raises an error for trailing characters after bang' do
      write_test_file [
        'ほげるとは',
        '　・・・',
        'ほげる！ あと何かをする',
      ]
      expect_error_text 'Trailing characters after bang'
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
      expect_error_text 'Cannot assign to a value'
    end

    it 'raises an error on trailing characters after funtion def' do
      write_test_file [
        'ほげるとは 何かな？',
      ]
      expect_error_text 'Unexpected input'
    end

    it 'raises an error when function def contains value' do
      write_test_file [
        '1を ほげるとは',
      ]
      expect_error_text 'Cannot declare function using primitives'
    end

    it 'raises an error when function def contains array' do
      write_test_file [
        'ほげ、ふが、ぴよを ほげる',
      ]
    end

    it 'raises an error when function def contains duplicate parameters' do
      write_test_file [
        'ほげと ほげを ふがるとは'
      ]
      expect_error_text 'Duplicate parameters'
    end

    it 'raises an error when missing parameters in function call' do
      write_test_file [
        'タベモノを 食べるとは',
        '　・・・',
        '食べる',
      ]
      expect_error_text 'Unexpected input'
    end

    it 'raises an error when calling function nonexistent in scope' do
      write_test_file [
        'ほげるとは',
        '　ふがるとは',
        '　　・・・',
        'ふがる',
      ]
      expect_error_text 'Unexpected input'
    end

    it 'raises an error when declaring non-verb-like function' do
      write_test_file [
        'ポテトとは',
        '　これは 「食べ物」',
      ]
      expect_error_text 'does not look like a verb'
    end

    it 'raises an error when calling function with wrong particles' do
      write_test_file [
        'タベモノを 食べるとは',
        '　・・・',
        '「ポテト」に 食べる',
      ]
      expect_error_text 'Unexpected input'
    end

    it 'raises an error when function call contains array primitive' do
      write_test_file [
        '1、2、3に 4を 追加する',
      ]
      expect_error_text 'Unexpected input'
    end

    it 'raises an error when re-declaring a function' do
      write_test_file [
        '言葉を 言うとは'
      ]
      expect_error_text 'has already been declared'
    end

    it 'raises an error when re-declaring a function regardless of parameter order' do
      write_test_file [
        'ほげと ふがを ぴようとは',
        '　・・・',
        'ふがと ほげを ぴようとは',
        '　・・・',
      ]
      expect_error_text 'has already been declared'
    end

    it 'raises an error when declaring function inside if statement' do
      write_test_file [
        'もし 引数を ほげるとは',
      ]
      expect_error_text 'Unexpected EOL'
    end

    it 'raises an error for unclosed if statements' do
      write_test_file [
        'もし 「ほげ」と 言う？',
      ]
      expect_error_text 'Unexpected EOL'
    end

    it 'raises an error for comments in if statements' do
      write_test_file [
        'もし 「ほげ」と 言う（コメント',
      ]
      expect_error_text 'Unexpected EOL'
    end

    it 'raises an error for undeclared variables in if statements' do
      write_test_file [
        'もし ほげが 1と 等しければ',
      ]
      expect_error_text 'Unexpected input'
    end

    it 'raises an error for else-if without if' do
      write_test_file [
        'または 「ほげ」と 言う（コメント',
      ]
      expect_error_text 'Unexpected else-if'
    end

    it 'raises an error for else without if' do
      write_test_file [
        'それ以外',
      ]
      expect_error_text 'Unexpected else'
    end
  end
end
