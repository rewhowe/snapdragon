require_relative 'conjugator.rb'
require_relative 'errors.rb'

module Tokenizer
  class Scope
    attr_reader :level
    attr_reader :parent
    attr_reader :type

    TYPE_MAIN         = :main
    TYPE_IF_BLOCK     = :if_block
    TYPE_FUNCTION_DEF = :function_def
    TYPE_LOOP         = :loop

    def initialize(parent = nil, type = TYPE_MAIN)
      @parent = parent
      @level = parent ? parent.level + 1 : 0
      @type = type

      @variables = {}
      @functions = {}
      @children = []
    end

    def add_variable(name)
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
    #             * force? - allow overriding functions with the same conjugated name
    #             * built_in? - true if the function is a built-in
    #             * conjugations - manually defined conjugations
    #
    # * function names will be automatically conjugated
    def add_function(name, signature = [], options = {})
      aliases = [name, *options[:aliases]]
      aliases += options[:conjugations] || aliases.map { |n| Conjugator.conjugate n } .reduce(&:+)

      aliases.each do |aliased_name|
        existing_function = get_function aliased_name, signature

        if existing_function && !options[:force?]
          raise Errors::FunctionDefAmbiguousConjugation.new [name, existing_function[:name]]
        end

        aliased_key = function_key aliased_name, signature
        @functions[aliased_key] = {
          name: options[:alias_of] || name,
          signature: signature,
          built_in?: options[:built_in?],
        }
      end
    end

    def get_function(name, signature)
      key = function_key name, signature
      @functions[key] || (@parent && @parent.get_function(name, signature))
    end

    def function?(name, signature = [])
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
