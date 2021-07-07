class BaseScope
  TYPE_MAIN         = :main
  TYPE_IF_BLOCK     = :if_block
  TYPE_FUNCTION_DEF = :function_def
  TYPE_LOOP         = :loop
  TYPE_TRY          = :try

  attr_reader :parent
  attr_reader :type

  def initialize(parent = nil, type = TYPE_MAIN)
    @parent = parent
    @type = type

    @variables = {}
    @functions = {}
  end

  def variable?(name)
    @variables.key?(name) || @parent&.variable?(name)
  end

  def holds_data?
    [TYPE_MAIN, TYPE_FUNCTION_DEF].include? @type
  end
end
