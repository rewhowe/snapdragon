require './spec/mock/reader'

RSpec.shared_context 'lexer' do
  include Mock::Tokenizer
  include Tokenizer

  around :example, :debug do |example|
    example.run
    @tokens.each do |token_info|
      puts token_info.join ' '
    end
  end

  def mock_reader(contents)
    @lexer = ::Tokenizer::Lexer.new Mock::Tokenizer::Reader.new contents
  end

  def tokens
    fail if @lexer.nil?
    tokens = []
    until (token = @lexer.next_token).nil? do
      tokens << token
    end
    @tokens = tokens.map { |t| [t.type, t.content, t.sub_type].compact }
  end
end
