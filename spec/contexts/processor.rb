require './src/interpreter/sd_array'
require './spec/mock/tokenizer/lexer'

RSpec.shared_context 'processor' do
  before(:each) do
    @mock_lexer = nil
    @options = { argv: [] }
  end

  def mock_lexer(*mock_tokens)
    @mock_lexer = Mock::Tokenizer::Lexer.new mock_tokens
  end

  def mock_options(options)
    @options = options
  end

  def execute
    @processor = ::Interpreter::Processor.new @mock_lexer, @options
    @processor.execute
  end

  def variable(name)
    @processor.instance_variable_get('@current_scope').get_variable name
  end

  def function(name)
    @processor.instance_variable_get('@current_scope').get_function name
  end

  def sore
    @processor.instance_variable_get :@sore
  end

  def are
    @processor.instance_variable_get :@are
  end

  def expect_error_unless_bang(tokens, error)
    mock_lexer(*tokens)
    expect { execute } .to_not raise_error

    mock_lexer(*tokens.reject { |t| t.type == Token::BANG })
    expect { execute } .to raise_error error
  end

  def sd_array(values = nil)
    case values
    when Array then Interpreter::SdArray.from_array values
    when Hash  then Interpreter::SdArray.from_hash values
    else Interpreter::SdArray.new
    end
  end
end
