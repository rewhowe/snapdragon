require './src/tokenizer/scope.rb'
require './src/tokenizer/errors.rb'

include Tokenizer

RSpec.describe Scope, 'variables and function scopes' do
  before :example do
    @current_scope = Scope.new
  end

  describe '#variable?' do
    it 'can recognize declared variables' do
      @current_scope.add_variable 'ホゲ'
      expect(@current_scope.variable?('ホゲ')).to be_truthy
    end

    it 'can recognize variables from parent scopes' do
      @current_scope.add_variable 'ホゲ'
      child_scope = Scope.new @current_scope
      expect(child_scope.variable?('ホゲ')).to be_truthy
    end
  end

  describe '#function?' do
    it 'can recognize defined functions' do
      @current_scope.add_function 'ほげる'
      expect(@current_scope.function?('ほげる')).to be_truthy
    end

    it 'can recognize defined functions by their conjugations' do
      @current_scope.add_function 'ほげる'
      expect(@current_scope.function?('ほげて')).to be_truthy
    end

    it 'can recognize defined functions regardless of parameter order' do
      parameters = [
        { name: 'a', particle: 'から' },
        { name: 'a', particle: 'と' },
        { name: 'a', particle: 'に' },
        { name: 'a', particle: 'へ' },
        { name: 'a', particle: 'まで' },
        { name: 'a', particle: 'で' },
        { name: 'a', particle: 'を' },
      ]
      @current_scope.add_function 'ほげる', parameters
      expect(@current_scope.function?('ほげて', parameters.reverse)).to be_truthy
    end

    it 'can recognize functions defined in parent scopes' do
      @current_scope.add_function 'ほげる'
      child_scope = Scope.new @current_scope
      expect(child_scope.function?('ほげて')).to be_truthy
    end
  end

  describe '#add_function' do
    it 'can shadow functions in delcared parent scopes' do
      @current_scope.add_function 'ほげる'
      child_scope = Scope.new @current_scope
      expect { child_scope.add_function 'ほげる' } .to_not raise_error
    end

    it 'raises an error when a duplicate function exists' do
      @current_scope.add_function 'ほげる'
      expect { @current_scope.add_function 'ほげる' } .to raise_error Errors::FunctionDefAmbiguousConjugation
    end

    it 'raises an error when a function with a duplicate conjugation exists' do
      @current_scope.add_function 'かう'
      expect { @current_scope.add_function 'かる' } .to raise_error Errors::FunctionDefAmbiguousConjugation
    end

    it 'can override duplicate conjugations of previously declared functions' do
      @current_scope.add_function 'かう'
      expect { @current_scope.add_function 'かる', [], force?: true } .to_not raise_error
    end
  end
end
