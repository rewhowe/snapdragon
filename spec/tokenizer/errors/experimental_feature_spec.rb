require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'
require './spec/contexts/errors'

# Contains various tests for partial implementations of future features.
# Tests may come and go from this file and may not be 'active'.
RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'
  include_context 'errors'

  describe '#next_token' do
    # TODO: (v1.1.0) Errors::AssignmentToReadOnlyAttribute
    # it 'raises an error when property is read-only' do
    #   mock_reader(
    #     "あれは 配列\n" \
    #     "あれの 長さは 1\n"
    #   )
    #   expect_error ExperimentalFeature
    # end

    # TODO: (v1.1.0)
    # it 'raises an error on an assignment into assignment' do
    #   mock_reader(
    #     "あれは 連想配列\n" \
    #     "あれは あれの 「ほげ」は 1\n"
    #   )
    #   expect_error ExperimentalFeature
    # end

    # TODO: (v1.1.0)
    # it 'raises an error on an if statement into assignment' do
    #   mock_reader(
    #     "あれは 連想配列\n" \
    #     "もし あれの 「ホゲ」は 1\n"
    #   )
    #   expect_error ExperimentalFeature
    # end

    # TODO: (v1.1.0)
    # it 'raises an error on indexing a string with a string' do
    #   mock_reader(
    #     "ホゲは 「ホゲ」の 「フガ」\n"
    #   )
    #   expect_error InvalidStringAttribute
    # end

    # TODO: (v1.1.0)
    # it 'raises an error when a property owner accesses itself as an attribute' do
    #   mock_reader(
    #     "あれは 連想配列\n" \
    #     "ホゲは あれの あれ\n"
    #   )
    #   expect_error AccessOfSelfAsAttribute
    # end

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
