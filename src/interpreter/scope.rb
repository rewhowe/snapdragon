require_relative 'formatter'

module Interpreter
  class Scope
    attr_reader :parent
    attr_reader :type

    # Tokens contained within function or loop scopes
    attr_reader :tokens
    # Parameter tokens for mapping function arguments
    attr_reader :parameters

    # TODO: (v1.0.0) move to base scope and share with Tokenizer::Scope
    TYPE_MAIN         = :main
    TYPE_IF_BLOCK     = :if_block
    TYPE_FUNCTION_DEF = :function_def
    TYPE_LOOP         = :loop

    def initialize(parent = nil, type = TYPE_MAIN, tokens = [], parameters = [])
      @parent = parent
      @type = type

      @variables = {}
      @functions = {}

      # Function or Loop body
      @tokens = tokens
      @token_ptr = 0
      @parameters = parameters
    end

    def set_variable(name, value)
      @variables[name] = value
    end

    def get_variable(name)
      @variables[name] || @parent&.get_variable(name)
    end

    def define_function(key, tokens, parameters)
      @functions[key] = Scope.new self, TYPE_FUNCTION_DEF, tokens, parameters
    end

    # Fetch a previously-defined function.
    # Params:
    # +key+:: the function name followed by the sorted, joined particles
    # +options+:: available options:
    #             * bubble_up? - if true: look for the function in parent scopes if not found
    def get_function(key, options = { bubble_up?: true })
      @functions[key] || (options[:bubble_up?] ? @parent&.get_function(key) : nil)
    end

    def current_token
      @tokens[@token_ptr]
    end

    def advance
      @token_ptr += 1
    end

    def reset
      @token_ptr = 0
    end

    def to_s
      format(
        "%sVariables:\n%s\nFunctions:\n%s\n",
        @parent ? @parent.to_s + "\n" : '',
        @variables.map { |k, v| "・#{k} => #{Formatter.format_output v}" } .join("\n"),
        @functions.keys.map { |f| "・#{f}" } .join("\n"),
      )
    end
  end
end
