require_relative '../base_scope'

require_relative 'conjugator'
require_relative 'errors'

module Tokenizer
  class Scope < BaseScope
    attr_reader :level

    def initialize(parent = nil, type = TYPE_MAIN)
      super parent, type

      @level = parent ? parent.level + 1 : 0

      @variables = {}
      @functions = {}
    end

    def add_variable(name)
      return @parent.add_variable name unless holds_data?
      @variables[name] = true
    end

    # Add a function with a given name and signature to the scope
    # Params:
    # +name+:: the function name (dictionary form)
    # +signature+:: the function signature of the format:
    #               { name: 'parameter name', particle: 'parameter particle' }
    # +options+:: available options:
    #             * names - names by which to call built-in functions
    #             * force? - allow overriding functions with the same conjugated name
    #             * built_in? - true if the function is a built-in
    #             * conjugations - manually defined conjugations
    #
    # * function names will be automatically conjugated
    def add_function(name, signature = [], options = {})
      return @parent.add_function name, signature, options unless holds_data?

      callable_names = options[:built_in?] ?  options[:names] : [name]
      callable_names += options[:conjugations] || callable_names.map { |n| Conjugator.conjugate n } .reduce(&:+)

      callable_names.each do |callable_name|
        existing_function = get_function callable_name, signature, bubble_up?: false

        if existing_function && !options[:force?]
          raise Errors::FunctionDefAmbiguousConjugation.new(name, existing_function[:name])
        end

        key = function_key callable_name, signature
        @functions[key] = {
          name: name,
          signature: signature,
          built_in?: options[:built_in?],
        }
      end
    end

    # Fetch a previously-defined function.
    # Params:
    # +name+:: the function name (dictionary form)
    # +signature+:: the function signature of the format:
    #               { name: 'parameter name', particle: 'parameter particle' }
    # +options+:: available options:
    #             * bubble_up? - if true: look for the function in parent scopes if not found
    def get_function(name, signature, options = nil)
      return @parent.get_function(name, signature, options) unless holds_data?

      options ||= { bubble_up?: true }
      key = function_key name, signature
      @functions[key] || (options[:bubble_up?] ? @parent&.get_function(name, signature) : nil)
    end

    def function?(name, signature = [], options = nil)
      !get_function(name, signature, options).nil?
    end

    def variable?(name)
      @variables.key?(name) || @parent&.variable?(name)
    end

    private

    def function_key(name, signature)
      name + signature.map { |parameter| parameter[:particle].to_s } .sort.join
    end
  end
end
