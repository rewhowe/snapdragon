require './src/tokenizer/lexer'
require './src/tokenizer/errors'

require './spec/contexts/lexer'

RSpec.describe Tokenizer::Lexer, 'error handling' do
  include_context 'lexer'

  describe '#next_token' do
    it 'raises an error when assigning to read-only property' do
      %w[
        長さ
        キー列
        先頭以外
        末尾以外
      ].each do |property|
        mock_reader(
          "それは 配列\n" \
          "それの #{property}は 2\n"
        )
        expect_error Tokenizer::Errors::AssignmentToReadOnlyProperty
      end
    end
  end
end
