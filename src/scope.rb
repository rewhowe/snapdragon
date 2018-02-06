require File.join(File.dirname(__FILE__), 'conjugator.rb')

class Scope
  attr_reader:level
#  attr_accessor :variables
#  attr_accessor :functions
#  attr_accessor :parent
  attr_accessor :children
  def initialize(parent=nil, level=0)
    @level = level
    @variables = {}
    @functions = {}
    @children = []
    @parent = parent
  end

  def add_variable(name)
    # TODO: maybe store the value, too?
    # we can simplify some stuff later if values are known
    @variables[name] = true
  end

  def add_function(name)
    @functions[name] = true
    Conjugator::conjugate(name).each do |conjugation|
      @functions[conjugation] = true
    end
  end

  ['variable', 'function'].each do |type|
    define_method "has_#{type}?" do |name|
      instance_variable_get("@#{type}s").has_key?(name) ||
        (@parent && @parent.send("has_#{type}?", name))
    end
  end
end
