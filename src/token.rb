class Token
  # rubocop:disable Layout/ExtraSpacing
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
    :RVALUE,         # [変数|値]
    # variable sub types
    :VARIABLE,       # 定義された変数
    :VAL_NUM,        # 数値
    :VAL_STR,        # 文字列
    :VAL_TRUE,       # ブーリアン型（true）
    :VAL_FALSE,      # ブーリアン型（false）
    :VAL_NULL,       # ヌル
    :VAL_ARRAY,      # 配列
    :VAR_SORE,       # グローバル変数（それ）
    :VAR_ARE,        # グローバル変数（あれ）

    # functions
    :PARAMETER,      # [変数|値][助詞]
    :FUNCTION_DEF,   # 関数定義
    :FUNCTION_CALL,  # 関数呼び出し
    :FUNC_BUILT_IN,  # ビルトイン関数
    :FUNC_USER,      # ユーザが定義した関数
    :RETURN,         # リターン

    # if structure
    :IF,             # 条件分岐開き
    :ELSE_IF,        # 次の条件分岐開き
    :ELSE,           # それ以外

    # comparators
    # 条件式、左側
    :COMP_1,         # [変数|値]が
    # 条件式、右側
    :COMP_2,         # [変数|値](後:[ハテナマーク])
    :COMP_2_TO,      # [変数|値]と
    :COMP_2_YORI,    # [変数|値]より
    :COMP_2_GTEQ,    # [変数|値]以上
    :COMP_2_LTEQ,    # [変数|値]以下
    # 条件式、演算子
    :COMP_3,         # ならば
    :COMP_3_NOT,     # でなければ
    :COMP_3_EQ,      # 等しければ
    :COMP_3_NEQ,     # 等しくなければ
    :COMP_3_GT,      # 大きければ
    :COMP_3_LT,      # 小さければ
    # 比較演算子
    :COMP_LT,        # A < B
    :COMP_LTEQ,      # A <= B
    :COMP_EQ,        # A == B
    :COMP_NEQ,       # A != B
    :COMP_GTEQ,      # A >= B
    :COMP_GT,        # A > B

    # loops
    :LOOP_ITERATOR,  # [変数][に] 対して
    :LOOP,           # 繰り返す
    :NEXT,           # 次
    :BREAK,          # 終わり

    # properties
    :PROPERTY,       # 所有
    :ATTRIBUTE,      # 属性
    # attribute sub types
    :ATTR_LEN,       # 属性：長さ
    :KEY_INDEX,      # 配列の添字
    :KEY_NAME,       # 連想配列のキー名
    :KEY_VAR,        # 連想配列のキー名を持つ変数

    # non-code
    :NO_OP,          # ・・・
    :DEBUG,          # 蛾

    # not used - maybe later?
    :SPACE,          # 空白文字
    :INDENT,         # 全角スペース
    :AND,
    :OR,
    :NOT,
  ].freeze
  # rubocop:enable Layout/ExtraSpacing
  TOKEN_TYPES.each { |constant| const_set(constant, constant.downcase) }

  attr_reader :type
  attr_reader :content
  attr_reader :sub_type
  attr_reader :particle

  def initialize(type, content = nil, **attrs)
    self.type     = type
    @content      = content
    self.sub_type = attrs[:sub_type] unless attrs[:sub_type].nil?
    @particle     = attrs[:particle]
  end

  def type=(type)
    raise "Invalid token type (#{type})" unless TOKEN_TYPES.include? type.upcase
    @type = type
  end

  def sub_type=(type)
    raise "Invalid token sub type (#{type})" unless TOKEN_TYPES.include? type.upcase
    @sub_type = type
  end

  def to_s
    @type.to_s
  end
end
