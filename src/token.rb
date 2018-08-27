class Token
  TOKEN_TYPES = [
    # meta
    :BOL,            # 行頭
    :EOL,            # 行末

    # punctuation
    :QUESTION,       # ハテナマーク
    :BANG,           # ビックリマーク
    :COMMA,          # カンマ

    # scope
    :SCOPE_BEGIN,    # 範囲明示文開き
    :SCOPE_CLOSE,    # 範囲明示文閉じ
    :ARRAY_BEGIN,    # 配列開き
    :ARRAY_CLOSE,    # 配列閉じ

    # variables
    :ASSIGNMENT,     # [変数]は
    :VARIABLE,       # [変数|値]
    :VAR_NUM,        # 数値
    :VAR_STR,        # 文字列
    :VAR_BOOL,       # ブーリアン型
    :VAR_ARRAY,      # 配列
    :VAR_SORE,       # グローバル変数（それ）
    :VAR_ARE,        # グローバル変数（あれ）

    # functions
    :PARAMETER,      # [変数|値][助詞]
    :FUNCTION_DEF,   # 関数定義
    :FUNCTION_CALL,  # 関数呼び出し

    # if structure
    :IF_START,       # 条件分岐開き
    :ELSE_IF_START,  # 次の条件分岐開き
    :IF_END,         # 条件分岐閉じ
    :ELSE,           # それ以外

    # comparators
    :COMPARATOR_1,   # 条件式、左側
    :COMPARATOR_2,   # 条件式、右側
    :COMP_LT,        # A < B
    :COMP_LTEQ,      # A <= B
    :COMP_EQ,        # A === B
    :COMP_NEQ,       # A !== B
    :COMP_GTEQ,      # A >= B
    :COM_GT,         # A > B

    # non-code
    :INLINE_COMMENT, # インラインコメント
    :BLOCK_COMMENT,  # ブロックコメント
    :COMMENT,        # コメントテキスト
    :NO_OP,          # ・・・

    # not used - maybe later?
    :SPACE,          # 空白文字
    :INDENT,         # 全角スペース
    # TODO: add support in if statements
    :AND,
    :OR,
    :NOT,
  ].freeze
  TOKEN_TYPES.each { |constant| const_set(constant, constant.downcase) }

  attr_accessor :type
  attr_accessor :content

  def initialize(type, content = nil)
    raise "Invalid token type (#{type})" unless TOKEN_TYPES.include? type.upcase
    @type = type
    @content = content
  end

  def to_s
    @type
  end
end
