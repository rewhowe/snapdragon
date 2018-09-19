require './src/tokenizer/lexer.rb'
require './src/tokenizer/token.rb'
require './src/tokenizer/errors.rb'

require './spec/contexts/lexer.rb'

include Tokenizer
include Errors

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'

  describe '#tokenize' do
    def expect_error(error)
      expect { Lexer.new(filename: @test_file.path).tokenize } .to raise_error error
    end

    it 'raises an error on unexpected EOL' do
      write_test_file [
        '変数は 1、'
      ]
      expect_error UnexpectedEol
    end

    it 'raises an error when missing tokens' do
      write_test_file [
        '変数は',
      ]
      expect_error UnexpectedEol
    end

    it 'raises an error when too much indent' do
      write_test_file [
        'インデントしすぎるとは',
        '　　行頭の空白は 「多い」',
      ]
      expect_error UnexpectedIndent
    end

    it 'raises an error for unclosed strings in variable declarations' do
      write_test_file [
        '変数はは 「もじれつ',
      ]
      expect_error UnclosedString
    end

    it 'raises an error for unclosed strings parameters' do
      write_test_file [
        'モジレツを 読むとは',
        '　・・・',
        '「もじれつを 読む',
      ]
      expect_error UnclosedString
    end

    it 'raises an error for trailing characters after bang' do
      write_test_file [
        'ほげるとは',
        '　・・・',
        'ほげる！ あと何かをする',
      ]
      expect_error TrailingCharacters
    end

    it 'raises an error on trailing characters in array declaration' do
      write_test_file [
        '変数は 「えっと」、「なんだっけ？」 と言った',
      ]
      expect_error TrailingCharacters
    end

    it 'raises an error when assigning to value' do
      write_test_file [
        '1は 2'
      ]
      expect_error AssignmentToValue
    end

    it 'raises an error on trailing characters after funtion def' do
      write_test_file [
        'ほげるとは 何かな？',
      ]
      expect_error UnexpectedInput
    end

    it 'raises an error when function def contains value' do
      write_test_file [
        '1を ほげるとは',
      ]
      expect_error FunctionDefPrimitiveParameters
    end

    it 'raises an error when function def contains array' do
      write_test_file [
        'ほげ、ふが、ぴよを ほげる',
      ]
      expect_error UnexpectedInput
    end

    it 'raises an error when function def contains duplicate parameters' do
      write_test_file [
        'ほげと ほげを ふがるとは'
      ]
      expect_error FunctionDefDuplicateParameters
    end

    it 'raises an error when missing parameters in function call' do
      write_test_file [
        'タベモノを 食べるとは',
        '　・・・',
        '食べる',
      ]
      expect_error UnexpectedInput
    end

    it 'raises an error when wrong parameters in function call' do
      write_test_file [
        'タベモノを 食べるとは',
        '　・・・',
        '1で 食べる',
      ]
      expect_error UnexpectedInput
    end

    it 'raises an error when calling function nonexistent in scope' do
      write_test_file [
        'ほげるとは',
        '　ふがるとは',
        '　　・・・',
        'ふがる',
      ]
      expect_error UnexpectedInput
    end

    it 'raises an error when declaring non-verb-like function' do
      write_test_file [
        'ポテトとは',
        '　これは 「食べ物」',
      ]
      expect_error FunctionDefNonVerbName
    end

    it 'raises an error when calling function with wrong particles' do
      write_test_file [
        'タベモノを 食べるとは',
        '　・・・',
        '「ポテト」に 食べる',
      ]
      expect_error UnexpectedInput
    end

    it 'raises an error when function call contains array primitive' do
      write_test_file [
        '1、2、3に 4を 追加する',
      ]
      expect_error UnexpectedInput
    end

    it 'raises an error when re-declaring a function' do
      write_test_file [
        '言葉を 言うとは'
      ]
      expect_error FunctionDefAlreadyDeclared
    end

    it 'raises an error when re-declaring a function regardless of parameter order' do
      write_test_file [
        'ほげと ふがを ぴようとは',
        '　・・・',
        'ふがと ほげを ぴようとは',
        '　・・・',
      ]
      expect_error FunctionDefAlreadyDeclared
    end

    it 'raises an error when declaring function inside if statement' do
      write_test_file [
        'もし 引数を ほげるとは',
      ]
      expect_error UnexpectedEol
    end

    it 'raises an error for unclosed if statements' do
      write_test_file [
        'もし 「ほげ」と 言う？',
      ]
      expect_error UnexpectedEol
    end

    it 'raises an error for comments in if statements' do
      write_test_file [
        'もし 「ほげ」と 言う（コメント',
      ]
      expect_error UnexpectedEol
    end

    it 'raises an error for undeclared variables in if statements' do
      write_test_file [
        'もし ほげが 1と 等しければ',
      ]
      expect_error UnexpectedInput
    end

    it 'raises an error for else-if without if' do
      write_test_file [
        'または 「ほげ」と 言う（コメント',
      ]
      expect_error UnexpectedElseIf
    end

    it 'raises an error for else without if' do
      write_test_file [
        'それ以外',
      ]
      expect_error UnexpectedElse
    end
  end
end
