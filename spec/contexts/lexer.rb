require './src/lexer.rb'
require './spec/contexts/test_file.rb'

RSpec.shared_context 'lexer' do
  include_context 'test_file'

  around :example, :debug do |example|
    example.run
    Lexer.tokenize(@test_file.path, { debug: true })
  end

  def tokens
    Lexer.tokenize(@test_file.path).map { |token| [token.type, token.content] }
  end
end
