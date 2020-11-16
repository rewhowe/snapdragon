class BaseScope
  TYPE_MAIN         = :main
  TYPE_IF_BLOCK     = :if_block
  TYPE_FUNCTION_DEF = :function_def
  TYPE_LOOP         = :loop

  attr_reader :parent
  attr_reader :type

  def initialize(parent = nil, type = TYPE_MAIN)
    @parent = parent
    @type = type
  end

  def has_own_data?
    [TYPE_MAIN, TYPE_FUNCTION_DEF].include? @type
  end
end
