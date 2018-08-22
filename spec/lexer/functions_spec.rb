require './src/lexer.rb'
require './src/token.rb'
require './spec/contexts/lexer.rb'

RSpec.describe Lexer, 'functions' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'tokenizes function declarations' do
    end
  end
end
