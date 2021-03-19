require './src/interpreter/sd_array'
require './spec/mock/tokenizer/lexer'

RSpec.shared_context 'processor' do
  def mock_lexer(*mock_tokens)
    @processor = ::Interpreter::Processor.new Mock::Tokenizer::Lexer.new mock_tokens
  end

  def execute
    @processor.execute
  end

  def variable(name)
    @processor.instance_variable_get('@current_scope').get_variable name
  end

  def function(name)
    @processor.instance_variable_get('@current_scope').get_function name
  end

  def sore
    @processor.instance_variable_get '@sore'
  end

  def expect_error_unless_bang(tokens, error)
    mock_lexer(*tokens)
    expect { @processor.execute } .to_not raise_error

    mock_lexer(*tokens.reject { |t| t.type == Token::BANG })
    expect { @processor.execute } .to raise_error error
  end

  def sd_array(values = nil)
    case values
    when Array then Interpreter::SdArray.from_array values
    when Hash  then Interpreter::SdArray.from_hash values
    else Interpreter::SdArray.new
    end
  end
end
