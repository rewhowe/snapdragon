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

  def expect_error_only_if_bang(tokens, error)
    mock_lexer(*tokens)
    expect { @processor.execute } .to raise_error error

    mock_lexer(*tokens.reject { |t| t.type == Token::BANG })
    expect { @processor.execute } .to_not raise_error
  end

  def sd_array(values = nil)
    sa = SdArray.new
    case values
    when Array
      0.upto(values.size - 1).zip(values).each { |k, v| sa.set k, v }
    when Hash
      values.each { |k, v| sa.set k, v }
    end
    sa
  end
end
