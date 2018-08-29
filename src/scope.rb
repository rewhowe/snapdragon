require_relative 'conjugator.rb'

# TODO: add tests for this file
class Scope
  attr_reader :level
  attr_accessor :parent
  attr_accessor :children
  attr_accessor :is_if_block

  attr_reader :variables
  attr_reader :functions

  def initialize(parent = nil, level = 0)
    @level = level
    @variables = {}
    @functions = {}
    @children = []
    @parent = parent
    @is_if_block = false
  end

  def add_variable(name)
    # TODO: maybe store the value, too?
    # we can simplify some stuff later if values are known
    @variables[name] = true
  end

  # Add a function with a given name and signature to the scope
  # Params:
  # +name+:: the function name (dictionary form)
  # +signature+:: the functoin signature of the format:
  #               { name: 'parameter name', particle: 'parameter particle' }
  #
  # * function names will be automatically conjugated
  def add_function(name, signature = [])
    key = function_key name, signature
    @functions[key] = { name: name, signature: signature }
    Conjugator.conjugate(name).each do |conjugation|
      conjugated_key = function_key conjugation, signature
      @functions[conjugated_key] = { name: name, signature: signature }
    end
  end

  def get_function(name, signature)
    key = function_key name, signature
    @functions[key] || (@parent && @parent.get_function(name, signature))
  end

  def function?(name, signature)
    key = function_key name, signature
    @functions.key?(key) || (@parent && @parent.function?(name, signature))
  end

  def variable?(name)
    @variables.key?(name) || (@parent && @parent.variable?(name))
  end

  private

  def function_key(name, signature)
    name + signature.map { |parameter| parameter[:particle].to_s } .join
  end
end
