require './src/lexer.rb'
require './src/token.rb'
require './spec/contexts/test_file_context.rb'

RSpec.describe Lexer, 'functions' do
  include_context 'uses_test_file'

  describe '#tokenize' do
    it 'tokenizes function declarations' do
    end
  end
end
