require './src/token'
require './src/interpreter/processor'
require './spec/contexts/interpreter'

RSpec.describe Interpreter::Processor, 'assignment' do
  include_context 'interpreter'

  describe '#process' do
    it 'processes built-in print_stdout' do
      mock_lexer(
        Token.new(Token::PARAMETER, '「ほげ」', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, '言う', sub_type: Token::FUNC_BUILT_IN),
      )
      expect { execute } .to output('ほげ').to_stdout
    end

    it 'processes built-in display_stdout' do
    end

    it 'processes built-in dump' do
    end

    it 'processes built-in throw' do
    end

    it 'processes built-in insert' do
    end

    it 'processes built-in concat' do
    end

    it 'processes built-in remove' do
    end

    it 'processes built-in remove_all' do
    end

    it 'processes built-in push' do
    end

    it 'processes built-in pop' do
    end

    it 'processes built-in unshift' do
    end

    it 'processes built-in shift' do
    end

    it 'processes built-in add' do
    end

    it 'processes built-in subtract' do
    end

    it 'processes built-in multiply' do
    end

    it 'processes built-in divide' do
    end

    it 'processes built-in mod' do
    end
  end
end
