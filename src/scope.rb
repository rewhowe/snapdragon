require_relative File.join('conjugator.rb')

class Scope
  attr_reader :level
  attr_accessor :parent
  attr_accessor :children

  def initialize(parent = nil, level = 0)
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

  def add_function(name, signature = [])
    @functions[name] = { name: name, signature: signature }
    Conjugator.conjugate(name).each do |conjugation|
      @functions[conjugation] = { name: name, signature: signature }
    end
  end

  def get_function(name)
    @functions[name] || (@parent && @parent.get_function(name))
  end

  %w[variable function].each do |type|
    define_method "#{type}?" do |name|
      instance_variable_get("@#{type}s").key?(name) ||
        (@parent && @parent.send("#{type}?", name))
    end
  end
end
