require './src/lexer.rb'
require './src/token.rb'
require './spec/contexts/lexer.rb'

RSpec.describe Lexer, 'values' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'tokenizes === if statement' do
      write_test_file [
        'もし 1が 1と 等しければ',
        '　・・・'
      ]

      fail
    end

    it 'closes if statement scope when next-line token unrelated' do
      write_test_file [
        'もし 1が 1と 等しければ',
        '　・・・',
        'ほげは 1',
      ]

      fail
    end
  end
end
