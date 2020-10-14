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
    it 'raises an error on trailing characters in array declaration' do
      mock_reader(
        "変数は 「えっと」、「なんだっけ？」 と言った\n"
      )
      expect_error TrailingCharacters
    end

    it 'raises an error on an assignment into if statement' do
      mock_reader(
        "あれは 配列\n" \
        "ホゲは あれの 長さ？ ならば\n"
      )
      expect_error TrailingCharacters
    end
  end
end
