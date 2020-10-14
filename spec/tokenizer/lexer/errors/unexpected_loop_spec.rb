require './src/tokenizer/lexer.rb'
require './src/tokenizer/errors.rb'

require './spec/contexts/lexer.rb'
require './spec/contexts/errors.rb'

include Tokenizer
include Errors

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'
  include_context 'errors'

  describe '#next_token' do
    it 'raises an error for an unexpected loop parameter' do
      mock_reader(
        "「永遠」に 繰り返す\n"
      )
      expect_error UnexpectedLoop
    end

    it 'raises an error for a loop inside an if condition' do
      mock_reader(
        "もし 「あいうえお」に 対して 繰り返す\n"
      )
      expect_error UnexpectedLoop
    end

    it 'raises an error on an assignment into loop' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さから あれの 長さまで 繰り返す\n"
      )
      expect_error UnexpectedLoop
    end

    it 'raises an error on an if statement into loop' do
      mock_reader(
        "あれは 配列\n" \
        "もし あれの 長さに 対して 繰り返す\n"
      )
      expect_error UnexpectedLoop
    end

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
