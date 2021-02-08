require './src/interpreter/scope'
require './src/interpreter/errors'

RSpec.describe Interpreter::Scope, 'variables and function scopes' do
  before :example do
    @current_scope = Interpreter::Scope.new
  end

  describe '#set_variable, #get_variable' do
    it 'can store and retrieve variables' do
      @current_scope.set_variable 'ホゲ', 1
      expect(@current_scope.get_variable('ホゲ')).to eq 1
    end

    it 'can store and retrieve variables from parent scopes (if not a function)' do
      @current_scope.set_variable 'ホゲ', 1
      child_scope = Interpreter::Scope.new @current_scope, Interpreter::Scope::TYPE_LOOP

      # child can read parent variable
      expect(child_scope.get_variable('ホゲ')).to eq 1

      # child can write parent variable
      child_scope.set_variable 'ホゲ', 2
      expect(@current_scope.get_variable('ホゲ')).to eq 2
    end

    it 'can store and retrieve its own copy of variales (if a function)' do
      @current_scope.set_variable 'ホゲ', 1
      child_scope = Interpreter::Scope.new @current_scope, Interpreter::Scope::TYPE_FUNCTION_DEF

      # child can read parent variable
      expect(child_scope.get_variable('ホゲ')).to eq 1

      # child cannot write parent variable
      child_scope.set_variable 'ホゲ', 2
      expect(child_scope.get_variable('ホゲ')).to eq 2
      expect(@current_scope.get_variable('ホゲ')).to eq 1
    end
  end

  describe '#define_function, #get_function' do
    it 'can define and retrieve functions' do
      @current_scope.define_function 'ほげる', [], []
      expect(@current_scope.get_function('ほげる')).to be_a Interpreter::Scope
    end

    it 'can retrieve functions from parent scopes' do
      @current_scope.define_function 'ほげる', [], []
      child_scope = Interpreter::Scope.new @current_scope, Interpreter::Scope::TYPE_FUNCTION_DEF
      expect(child_scope.get_function('ほげる')).to be_a Interpreter::Scope
    end

    it 'returns a copy of returned functions (to avoid memory pollution)' do
      @current_scope.define_function 'ほげる', [], []

      original_function = @current_scope.instance_variable_get('@functions')['ほげる']
      original_function.set_variable 'ホゲ', 1

      copied_function = @current_scope.get_function 'ほげる'
      copied_function.set_variable 'ホゲ', 2

      expect(copied_function.get_variable('ホゲ')).to eq 2
      expect(original_function.get_variable('ホゲ')).to eq 1
    end
  end
end
