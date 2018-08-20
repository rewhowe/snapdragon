require './src/lexer.rb'
require './src/token.rb'

RSpec.describe Lexer do
  def write_contents(contents)
    @test_file.open
    @test_file.write contents.join "\n"
    @test_file.close
  end

  before :all do
    @test_file = Tempfile.new('testfile')
  end

  after :all do
    @test_file.delete
  end

  describe '#tokenize' do
    it 'tokenizes variable declarations' do
      write_contents [
        'ほげは 10',
      ]

      tokens = Lexer.tokenize(@test_file.path).map { |token| [ token.type, token.content ] }

      expect(tokens).to contain_exactly(
        [ Token::ASSIGNMENT, 'ほげ' ],
        [ Token::VARIABLE, '10' ],
      )
    end
  end
end
