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

    # other
    :SPACE,          # 空白文字
    :INDENT,         # 全角スペース
    # TODO: make sub types for different types of variables
    :VARIABLE,       # [変数|値]
    :ASSIGNMENT,     # [変数]は
    :PARAMETER,      # [変数|値][助詞]
    # TODO: keep track of parameters / particles
    :FUNCTION_DEF,   # 関数定義
    :FUNCTION_CALL,  # 関数呼び出し
    :INLINE_COMMENT, # コメント
    :BLOCK_COMMENT,  # ブロックコメント
    :AND,            # と
    :NO_OP,          # ・・・
  ]
  TOKEN_TYPES.each { |constant| const_set(constant, constant) }

  attr_accessor :type
  attr_accessor :content

  def initialize(type, content=nil)
    raise 'Invalid token type' unless TOKEN_TYPES.include? type
    @type = type
    @content = content
  end

  def to_s
    @type
  end
end
