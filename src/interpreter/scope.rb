module Interpreter
  class Scope
    attr_reader :parent
    attr_reader :type

    attr_accessor :tokens

    # TODO: move to base scope and share with Tokenizer::Scope
    TYPE_MAIN         = :main
    TYPE_IF_BLOCK     = :if_block
    TYPE_FUNCTION_DEF = :function_def
    TYPE_LOOP         = :loop

    def initialize(parent = nil, type = TYPE_MAIN)
      @parent = parent
      @type = type

      @variables = {}
      @functions = {}

      # Function or Loop body
      @tokens = []
      @token_ptr = 0
    end

    def set_variable(name, value)
      @variables[name] = value
    end

    def get_variable(name)
      @variables[name] || @parent&.get_variable(name)
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
      [
        @parent&.to_s,
        "\n",
        'Variables:',
        @variables.map { |k, v| "・#{k} => #{v}" } .join("\n"),
        'Functions:',
        @functions.keys.map { |f| "・#{f}" } .join("\n"),
      ].compact.join("\n")
    end
  end
end
