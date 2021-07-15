require_relative 'util/i18n'

class Token
  # rubocop:disable Layout/ExtraSpacing
  TOKEN_TYPES = [
    # meta
    :BOL, # 行頭
    :EOL, # 行末

    # punctuation
    :QUESTION, # ハテナマーク
    :BANG,     # ビックリマーク
    :COMMA,    # カンマ

    # scope
    :SCOPE_BEGIN, # 範囲明示文開き
    :SCOPE_CLOSE, # 範囲明示文閉じ
    :ARRAY_BEGIN, # 配列開き
    :ARRAY_CLOSE, # 配列閉じ

    # variables
    :ASSIGNMENT, # 代入 / 定義
    :TOPIC,      # [変数]は
    :RVALUE,     # [変数|値]
    # variable sub types
    :VARIABLE,   # 定義された変数
    :VAL_NUM,    # 数値
    :VAL_STR,    # 文字列
    :VAL_TRUE,   # ブーリアン型（true）
    :VAL_FALSE,  # ブーリアン型（false）
    :VAL_NULL,   # ヌル
    :VAL_ARRAY,  # 配列
    :VAR_SORE,   # グローバル変数（それ）
    :VAR_ARE,    # グローバル変数（あれ）

    # functions
    :PARAMETER,     # [変数|値][助詞]
    :FUNCTION_DEF,  # 関数定義
    :FUNCTION_CALL, # 関数呼び出し
    :FUNC_BUILT_IN, # ビルトイン関数
    :FUNC_USER,     # ユーザが定義した関数
    :RETURN,        # リターン

    # if structure
    :IF,      # 条件分岐開き
    :ELSE_IF, # 次の条件分岐開き
    :ELSE,    # それ以外

    # comparators
    # 条件式、左側
    :SUBJECT,          # [変数|値]が
    # 条件式、右側
    :COMP_1,           # [変数|値](後:[ハテナマーク])
    :COMP_1_TO,        # [変数|値]と
    :COMP_1_EQ,        # 同じ
    :COMP_1_YORI,      # [変数|値]より
    :COMP_1_GTEQ,      # [変数|値]以上
    :COMP_1_LTEQ,      # [変数|値]以下
    :COMP_1_EMP,       # 空
    :COMP_1_IN,        # (前:[変数|値|]の) 中に
    # 条件式、演算子
    ## 仮定形
    :COMP_2,           # ならば
    :COMP_2_NOT,       # でなければ
    :COMP_2_GT,        # 大きければ
    :COMP_2_LT,        # 小さければ
    :COMP_2_BE,        # あれば
    :COMP_2_NBE,       # なければ
    ## 連用形
    :COMP_2_CONJ,      # であり
    :COMP_2_NOT_CONJ,  # でなく
    :COMP_2_GT_CONJ,   # 大きく
    :COMP_2_LT_CONJ,   # 小さく
    :COMP_2_BE_CONJ,   # あり
    :COMP_2_NBE_CONJ,  # なく
    ## 連体形
    :COMP_2_TRUE_MOD,  # である
    :COMP_2_FALSE_MOD, # である
    :COMP_2_MOD,       # である
    :COMP_2_NOT_MOD,   # でない
    :COMP_2_GT_MOD,    # 大きい
    :COMP_2_LT_MOD,    # 小さい
    :COMP_2_BE_MOD,    # ある
    :COMP_2_NBE_MOD,   # ない
    # 比較演算子
    :COMP_LT,          # A < B
    :COMP_LTEQ,        # A <= B
    :COMP_EQ,          # A == B
    :COMP_NEQ,         # A != B
    :COMP_GTEQ,        # A >= B
    :COMP_GT,          # A > B
    # その他条件式用演算子
    :COMP_EMP,         # A.empty?
    :COMP_NEMP,        # ! A.empty?
    :COMP_IN,          # A.in? B
    :COMP_NIN,         # ! A.in? B
    # その他条件式用トークン、接続詞
    :AND,              # 且つ
    :OR,               # 又は

    # loops
    :LOOP_ITERATOR, # [変数][に] 対して
    :LOOP,          # 繰り返す
    :WHILE,         # [条件式の] 限り [繰り返す]
    :NUM_TIMES,     # [数値]回
    :NEXT,          # 次
    :BREAK,         # 終わり

    # properties
    :POSSESSIVE,      # 所有
    :PROPERTY,        # 属性
    # property sub types
    :PROP_LEN,        # 属性：長さ
    :PROP_KEYS,       # キー列
    :PROP_FIRST,      # 先頭の要素
    :PROP_LAST,       # 末尾の要素
    :PROP_FIRST_IGAI, # 先頭以外の要素列
    :PROP_LAST_IGAI,  # 末尾以外の要素列
    :PROP_EXP,        # 数値の乗
    :PROP_EXP_SORE,   # 数値のその乗
    :PROP_EXP_ARE,    # 数値のその乗
    :PROP_ROOT,       # 数値の乗根
    :PROP_ROOT_SORE,  # 数値のその乗根
    :PROP_ROOT_ARE,   # 数値のその乗根
    :KEY_INDEX,       # 配列の添字
    :KEY_NAME,        # 連想配列のキー名
    :KEY_VAR,         # 連想配列のキー名を持つ変数
    :KEY_SORE,        # キー名を持つグローバル変数（それ）
    :KEY_ARE,         # キー名を持つグローバル変数（あれ）

    # try
    :TRY, # 試す

    # log (math)
    :LOG_BASE,  # 底
    :LOGARITHM, # 対数

    # misc
    :NO_OP, # ・・・
    :DEBUG, # 蛾
    :SURU,  # する
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
    raise Util::I18n.t('internal_errors.invalid_token_type', type) unless TOKEN_TYPES.include? type.upcase
    @type = type
  end

  def sub_type=(type)
    raise Util::I18n.t('internal_errors.invalid_token_sub_type', type) unless TOKEN_TYPES.include? type.upcase
    @sub_type = type
  end

  def to_s
    @type.to_s
  end
end
