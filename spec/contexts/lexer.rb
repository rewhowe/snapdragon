require './spec/mock/tokenizer/reader'

RSpec.shared_context 'lexer' do
  RSpec::Matchers.define :contain_exactly_in_order do |*expected|
    @differing_index = nil
    match do |actual|
      expected.each.with_index do |expected_element, i|
        unless actual[i] == expected_element
          @differing_index = i
          return false
        end
      end

      unless expected.length == actual.length
        @differing_index = expected.length
        return false
      end

      true
    end

    failure_message do |actual|
      "expected\n#{format_tokens actual}\nto contain exactly in order\n#{format_tokens expected}"
    end

    def format_tokens(tokens)
      [].tap do |lines|
        tokens.each.with_index do |token, i|
          if i == @differing_index
            lines << "> #{token}"
            break
          else
            lines << "  #{token}"
          end
        end
      end .join "\n"
    end
  end

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

  def expect_error(error)
    expect { tokens } .to raise_error error
  end

  def expect_string_interpolation_error(string, error)
    mock_reader ''
    expect { @lexer.interpolate_string string } .to raise_error error
  end
end
