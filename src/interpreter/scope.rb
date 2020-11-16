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

    def initialize_copy(source)
      super
      # variables and functions must be fresh in order to avoid polluting other instances
      @variables = {}
      @functions = {}
      # tokens (the body) and parameters are read-only and thus do not need to be duped
      @tokens = source.tokens
      @token_ptr = 0
      @parameters = source.parameters
    end

    def set_variable(name, value)
      @parent.set_variable name, value unless [TYPE_MAIN, TYPE_FUNCTION_DEF].include? @type
      @variables[name] = value
    end

    def get_variable(name)
      @variables.key?(name) ? @variables[name] : @parent&.get_variable(name)
    end

    def define_function(key, body_tokens, parameters)
      @parent.define_function key, body_tokens, parameters unless [TYPE_MAIN, TYPE_FUNCTION_DEF].include? @type

      @functions[key] = Scope.new self, TYPE_FUNCTION_DEF, body_tokens, parameters
    end

    # Fetch a previously-defined function.
    # Params:
    # +key+:: the function name followed by the sorted, joined particles
    # +options+:: available options:
    #             * bubble_up? - if true: look for the function in parent scopes if not found
    def get_function(key, options = { bubble_up?: true })
      function = @functions[key] || (options[:bubble_up?] ? @parent&.get_function(key) : nil)
      # return a duplicate to avoid polluting parent scopes during recursion
      function&.dup
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
        "%<parent>sVariables:\n%<variables>s\nFunctions:\n%<functions>s\n",
        parent: @parent ? @parent.to_s + "\n" : '',
        variables: @variables.map { |k, v| "・#{k} => #{Formatter.output v}" } .join("\n"),
        functions: @functions.keys.map { |f| "・#{f}" } .join("\n")
      )
    end
  end
end
