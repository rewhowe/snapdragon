require './src/tokenizer/lexer.rb'
require './src/tokenizer/errors.rb'

require './spec/contexts/lexer.rb'
require './spec/contexts/errors.rb'

include Tokenizer
include Errors

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'
  include_context 'errors'

  # TODO: split up into individual errors
  describe '#next_token' do
    it 'raises an error when property owner is not a variable or string' do
      mock_reader(
        "ほげは 1の 長さ\n"
      )
      expect_error InvalidPropertyOwner
    end

    it 'raises an error when a property owner cannot yield a valid attribute as a loop iterator parameter' do
      mock_reader(
        "「ほげ」の 長さに 対して 繰り返す\n"
      )
      expect_error InvalidPropertyOwner
    end

    it 'raises an error when property owner does not exist' do
      mock_reader(
        "ほげは ふがの 長さ\n"
      )
      expect_error VariableDoesNotExist
    end

    it 'raises an error for undeclared variables in if statements' do
      mock_reader(
        "もし ほげが 1と 等しければ\n"
      )
      expect_error VariableDoesNotExist
    end

    it 'raises an error for undeclared variables in function calls' do
      mock_reader(
        "配列に ほげを 追加する\n"
      )
      expect_error VariableDoesNotExist
    end

    describe '#next_token' do
      it 'raises an error on a non-existent return parameter' do
        mock_reader(
          "存在しない変数を 返す\n"
        )
        expect_error VariableDoesNotExist
      end
    end

    it 'raises an error when property is invalid (attribute)' do
      mock_reader(
        "あれは 配列\n" \
        "ほげは あれの ふが\n"
      )
      expect_error AttributeDoesNotExist
    end

    # Covers function call, loop, loop iterator, and return
    it 'raises an error when property is invalid (parameter)' do
      mock_reader(
        "あれは 配列\n" \
        "あれの ふがに 対して 繰り返す\n"
      )
      expect_error AttributeDoesNotExist
    end

    # TODO: (v1.1.0) Errors::AssignmentToReadOnlyAttribute
    # it 'raises an error when property is read-only' do
    #   mock_reader(
    #     "あれは 配列\n" \
    #     "あれの 長さは 1\n"
    #   )
    #   expect_error ExperimentalFeature
    # end

    it 'raises an error when looping over a length attribute' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さに 対して 繰り返す\n"
      )
      expect_error InvalidLoopParameter
    end

    # TODO: (v1.1.0)
    # it 'raises an error on an assignment into assignment' do
    #   mock_reader(
    #     "あれは 連想配列\n" \
    #     "あれは あれの 「ほげ」は 1\n"
    #   )
    #   expect_error MultipleAssignment
    # end

    it 'raises an error on an assignment into function def' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さを ほげるとは\n"
      )
      expect_error InvalidFunctionDefParameter
    end

    it 'raises an error on an assignment into function call' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さを 足す\n"
      )
      expect_error UnexpectedFunctionCall
    end

    it 'raises an error on an assignment into if statement' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さ？ ならば\n"
      )
      expect_error TrailingCharacters
    end

    it 'raises an error on an assignment into loop' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さから あれの 長さまで 繰り返す\n"
      )
      expect_error UnexpectedLoop
    end

    it 'raises an error on an assignment into if return' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さを 返す\n"
      )
      expect_error UnexpectedReturn
    end

    it 'raises an error on property inside function def' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さを ほげるとは\n"
      )
      expect_error InvalidFunctionDefParameter
    end

    it 'raises an error on an unfinished if statement with properies' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さ\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error on a sudden if statement with properies (by token sequence)' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さが 0？ ならば\n"
      )
      expect_error UnexpectedInput
    end

    it 'raises an error on a sudden if statement with properies (by close if check)' do
      mock_reader(
        "あれは 配列\n" \
        "あれの 長さより 高ければ\n"
      )
      expect_error UnexpectedComparison
    end

    # TODO: (v1.1.0)
    # it 'raises an error on an if statement into assignment' do
    #   mock_reader(
    #     "あれは 連想配列\n" \
    #     "もし あれの 「ホゲ」は 1\n"
    #   )
    #   expect_error ExperimentalFeature
    # end

    it 'raises an error on an if statement into function def ' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さを ほげるとは\n"
      )
      expect_error UnexpectedFunctionDef
    end

    it 'raises an error on an if statement into loop' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さに 対して 繰り返す\n"
      )
      expect_error UnexpectedLoop
    end

    it 'raises an error on an if statement into multiple comp1' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さが あれの 長さが あれの 長さ？ ならば\n"
      )
      expect_error InvalidPropertyComparison
    end

    it 'raises an error on indexing a string with a string' do
      mock_reader(
        "ホゲは 「ホゲ」の 「フガ」\n"
      )
      expect_error InvalidStringAttribute
    end

    # TODO: (v1.1.0)
    # it 'raises an error when a property owner accesses itself as an attribute' do
    #   mock_reader(
    #     "あれは 連想配列\n" \
    #     "ホゲは あれの あれ\n"
    #   )
    #   expect_error AccessOfSelfAsAttribute
    # end

    it 'raises an error when assigning a variable to itself' do
      mock_reader(
        "ホゲは ホゲ\n"
      )
      expect_error UnexpectedInput
    end

    # TODO: (v1.1.0)
    # it 'raises an error when assigning a key variable to itself' do
    #   mock_reader(
    #     "ホゲは 連想配列\n" \
    #     "ホゲの フガは ホゲの フガ\n"
    #   )
    #   expect_error ExperimentalFeature
    # end

    # TODO: (v1.1.0)
    # it 'raises an error when assigning a key name to itself' do
    #   mock_reader(
    #     "ホゲは 連想配列\n" \
    #     "ホゲの 「ふが」は ホゲの 「ふが」\n"
    #   )
    #   expect_error ExperimentalFeature
    # end

    # TODO: (v1.1.0)
    # it 'raises an error when assigning a property owner to its own attribute' do
    #   mock_reader(
    #     "ホゲは 連想配列\n" \
    #     "ホゲの 「ふが」は ホゲ\n"
    #   )
    #   expect_error ExperimentalFeature
    # end
  end
end
