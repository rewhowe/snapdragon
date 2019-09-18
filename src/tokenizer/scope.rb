require_relative 'conjugator.rb'

# TODO: add tests for this file
module Tokenizer
  class Scope
    attr_reader :level
    attr_accessor :parent
    attr_accessor :children
    attr_accessor :is_if_block

    attr_reader :variables
    attr_reader :functions

    def initialize(parent = nil)
      @parent = parent
      @level = parent ? parent.level + 1 : 0

      @variables = {}
      @functions = {}
      @children = []
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
    # +signature+:: the function signature of the format:
    #               { name: 'parameter name', particle: 'parameter particle' }
    # +options+:: available options:
    #             * alias_of - function name of which the added function is an alias
    #             * aliases - additional names by which to call the added function
    #
    # * function names will be automatically conjugated
    def add_function(name, signature = [], options = {})
      raise "Cannot redeclare function #{name}" if function? name, signature

      key = function_key name, signature
      @functions[key] = { name: options[:alias_of] || name, signature: signature }

      aliases = Conjugator.conjugate(name) + (options[:aliases] || [])

      aliases.each do |aliased_name|
        aliased_key = function_key aliased_name, signature
        @functions[aliased_key] = { name: options[:alias_of] || name, signature: signature }
      end
    end

    def get_function(name, signature)
      key = function_key name, signature
      @functions[key] || (@parent && @parent.get_function(name, signature))
    end

    def function?(name, signature)
      !get_function(name, signature).nil?
    end

    def variable?(name)
      @variables.key?(name) || (@parent && @parent.variable?(name))
    end

    private

    def function_key(name, signature)
      name + signature.map { |parameter| parameter[:particle].to_s } .sort.join
    end
  end
end
