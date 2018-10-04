require './spec/contexts/test_file.rb'

include Tokenizer

RSpec.shared_context 'lexer' do
  include_context 'test_file'

  around :example, :debug do |example|
    example.run
    Lexer.new(debug: true, filename: @test_file.path).tokenize
  end

  def tokens
    Lexer.new(filename: @test_file.path).tokenize.map { |token| [token.type, token.content].compact }
  end
end
