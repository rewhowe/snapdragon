require './src/tokenizer/lexer.rb'
require './src/tokenizer/token.rb'
require './src/tokenizer/errors.rb'

require './spec/contexts/lexer.rb'

include Tokenizer
include Errors

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    def expect_error(error)
      expect { tokens } .to raise_error error
    end

    it 'raises an error on unexpected EOL' do
      mock_reader(
        "変数は 1、\n"
      )
      expect_error UnexpectedEol
    end

    it 'raises an error when missing tokens' do
      mock_reader(
        "変数は\n"
      )
      expect_error UnexpectedEol
    end

    it 'raises an error when too much indent' do
      mock_reader(
        "インデントしすぎるとは\n" \
        "　　行頭の空白は 「多い」\n"
      )
      expect_error UnexpectedIndent
    end

    it 'raises an error for unclosed strings in variable declarations' do
      mock_reader(
        "変数はは 「もじれつ\n"
      )
      expect_error UnclosedString
    end

    it 'raises an error for unclosed strings parameters' do
      mock_reader(
        "モジレツを 読むとは\n" \
        "　・・・\n" \
        "「もじれつを 読む\n"
      )
      expect_error UnclosedString
    end

    it 'raises an error for unclosed block comments' do
      mock_reader(
        "※このブロックコメントは曖昧\n"
      )
      expect_error UnclosedBlockComment
    end

    it 'raises an error for trailing characters after bang' do
      mock_reader(
        "ほげるとは\n" \
        "　・・・\n" \
        "ほげる！ あと何かをする\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error on trailing characters in array declaration' do
      mock_reader(
        "変数は 「えっと」、「なんだっけ？」 と言った\n"
      )
      expect_error TrailingCharacters
    end

    it 'raises an error when assigning to value' do
      mock_reader(
        "1は 2\n"
      )
      expect_error AssignmentToValue
    end

    it 'raises an error on trailing characters after funtion def' do
      mock_reader(
        "ほげるとは 何かな？\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when function def contains value' do
      mock_reader(
        "1を ほげるとは\n"
      )
      expect_error FunctionDefPrimitiveParameters
    end

    it 'raises an error when function def contains array' do
      mock_reader(
        "ほげ、ふが、ぴよを ほげる\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when function def contains duplicate parameters' do
      mock_reader(
        "ほげと ほげを ふがるとは\n"
      )
      expect_error FunctionDefDuplicateParameters
    end

    it 'raises an error when missing parameters in function call' do
      mock_reader(
        "タベモノを 食べるとは\n" \
        "　・・・\n" \
        "食べる\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when wrong parameters in function call' do
      mock_reader(
        "タベモノを 食べるとは\n" \
        "　・・・\n" \
        "1で 食べる\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when calling function nonexistent in scope' do
      mock_reader(
        "ほげるとは\n" \
        "　ふがるとは\n" \
        "　　・・・\n" \
        "ふがる\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when declaring non-verb-like function' do
      mock_reader(
        "ポテトとは\n" \
        "　これは 「食べ物」\n"
      )
      expect_error FunctionDefNonVerbName
    end

    it 'raises an error when calling function with wrong particles' do
      mock_reader(
        "タベモノを 食べるとは\n" \
        "　・・・\n" \
        "「ポテト」に 食べる\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when function call contains array primitive' do
      mock_reader(
        "1、2、3に 4を 追加する\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when function call contains an undeclared variable' do
      mock_reader(
        "ほげを 追加する\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error when re-declaring a function' do
      mock_reader(
        "言葉を 言うとは\n"
      )
      expect_error FunctionDefAlreadyDeclared
    end

    it 'raises an error when re-declaring a function regardless of parameter order' do
      mock_reader(
        "ほげと ふがを ぴよるとは\n" \
        "　・・・\n" \
        "ふがと ほげを ぴよるとは\n" \
        "　・・・\n"
      )
      expect_error FunctionDefAlreadyDeclared
    end

    it 'raises an error when declaring function inside if statement' do
      mock_reader(
        "もし 引数を ほげるとは\n"
      )
      expect_error UnexpectedFunctionDef
    end

    it 'raises an error for unclosed if statements' do
      mock_reader(
        "もし 「ほげ」と 言う？\n"
      )
      expect_error UnexpectedEol
    end

    it 'raises an error for comments in if statements' do
      mock_reader(
        "もし 「ほげ」と 言う（コメント\n"
      )
      expect_error UnexpectedEol
    end

    it 'raises an error for undeclared variables in if statements' do
      mock_reader(
        "もし ほげが 1と 等しければ\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error for else-if without if' do
      mock_reader(
        "または 「ほげ」と 言う（コメント\n"
      )
      expect_error UnexpectedElseIf
    end

    it 'raises an error for else without if' do
      mock_reader(
        "それ以外\n"
      )
      expect_error UnexpectedElse
    end

    it 'raises an error for defining a method with a reserved name' do
      mock_reader(
        "エラーを 繰り返すとは\n"
      )
      expect_error FunctionDefReserved
    end

    it 'raises an error for missing loop iterator parameter' do
      mock_reader(
        "対して 繰り返す\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error for an invalid loop iterator particle' do
      mock_reader(
        "「永遠」を 対して 繰り返す\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error for an invalid loop iterator parameter (non-existent variable)' do
      mock_reader(
        "存在しない変数に 対して 繰り返す\n"
      )
      expect_error InvalidLoopParameter
    end

    it 'raises an error for an invalid loop iterator parameter (non-string primitive)' do
      mock_reader(
        "1に 対して 繰り返す\n"
      )
      expect_error InvalidLoopParameter
    end

    it 'raises an error for an unexpected loop parameter' do
      mock_reader(
        "「永遠」に 繰り返す\n"
      )
      expect_error UnexpectedLoop
    end

    it 'raises an error for invalid loop parameter particle (1)' do
      mock_reader(
        "1に 3まで 繰り返す\n"
      )
      expect_error InvalidLoopParameter
    end

    it 'raises an error for invalid loop parameter type (1)' do
      mock_reader(
        "「1」から 3まで 繰り返す\n"
      )
      expect_error InvalidLoopParameter
    end

    it 'raises an error for invalid loop parameter particle (2)' do
      mock_reader(
        "1から 100に 繰り返す\n"
      )
      expect_error InvalidLoopParameter
    end

    it 'raises an error for invalid loop parameter type (2)' do
      mock_reader(
        "1から 「100」まで 繰り返す\n"
      )
      expect_error InvalidLoopParameter
    end

    it 'raises an error for next inside an unexpected scope' do
      mock_reader(
        "ほげるとは\n" \
        "　次\n"
      )
      expect_error UnexpectedScope
    end

    it 'raises an error for declaring a variable with a reserved name' do
      mock_reader(
        "大きさは 10\n"
      )
      expect_error VariableNameReserved
    end

    it 'raises an error for declaring a variable with a name already declared as a function' do
      mock_reader(
        "ほげるとは\n" \
        "　・・・\n" \
        "ほげるは 10\n"
      )
      expect_error VariableNameAlreadyDelcaredAsFunction
    end
  end
end
