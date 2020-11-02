require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'
require './spec/contexts/errors'

include Tokenizer
include Errors

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'
  include_context 'errors'

  describe '#next_token' do
    # TODO: (v1.1.0)
    # it 'raises an error on assignment with property into loop iterator' do
    #   mock_reader(
    #     "あれは 配列\n" \
    #     "ホゲは あれの 「フガ」に 対して 繰り返す\n"
    #   )
    #   expect_error UnexpectedLoop
    # end

    # TODO: (v1.1.0)
    # it 'raises an error on assignment with property into loop' do
    #   mock_reader(
    #     "あれは 配列\n" \
    #     "ホゲは あれの 長さから 0まで 繰り返す\n"
    #   )
    #   expect_error UnexpectedLoop
    # end
  end
end
