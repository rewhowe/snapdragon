require './src/lexer.rb'
require './src/token.rb'
require './spec/contexts/lexer.rb'

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'raises an error when missing tokens' do
      write_test_file [
        '変数は',
      ]

      expect { Lexer.tokenize(@test_file.path) } .to raise_error StandardError
    end
  end
end
