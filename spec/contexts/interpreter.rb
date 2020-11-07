require './spec/mock/tokenizer/lexer'

RSpec.shared_context 'interpreter' do
  def mock_lexer(*mock_tokens)
    @interpreter = ::Interpreter::Processor.new Mock::Tokenizer::Lexer.new mock_tokens
  end

  def execute
    @interpreter.execute
  end

  def variable(name)
    @interpreter.instance_variable_get('@current_scope').get_variable name
  end

  def function(name)
    @interpreter.instance_variable_get('@current_scope').get_function name
  end
end
