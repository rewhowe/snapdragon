# TODO: allow multiple different signatures
# TODO: make tests for the above
# TODO: during compilation, use macros/inlines instead of actual function calls
module BuiltIns
  BUILT_INS = {
    # TODO: add signature with を
    %w[言う いう] => [ # printf / print / console.log / etc
      { name: '言葉', particle: 'と' }
      # TODO: { name: '言葉', particle: 'を' }
    ],
    %w[ログする] => [ # output to log / console.log / etc
      { name: 'メッセージ', particle: 'を' }
    ],
    %w[表示する] => [ # std out / print / alert / etc
      { name: 'メッセージ', particle: 'を' }
    ],
    %w[叫ぶ さけぶ] => [ # std err / print / alert / etc
      { name: 'コトバ', particle: 'を' }
    ],
    %w[追加する] => [ # append
      { name: '追加対象', particle: 'を' },
      { name: '対象列', particle: 'に' },
    ],
    %w[連結する] => [ # concatenate
      { name: '連結対象', particle: 'を' },
      { name: '対象列', particle: 'に' },
    ],
    %w[抜く ぬく] => [
      { name: '対象列', particle: 'から' },
      { name: '抜き対象', particle: 'を' },
    ],
    %w[全部抜く 全部ぬく] => [
      { name: '対象列', particle: 'から' },
      { name: '抜き対象', particle: 'を' }
    ],
    %w[足す たす] => [ # addition 加法
      { name: '被加数', particle: 'に' },
      { name: '加数', particle: 'を' },
      # TODO: alternates
    ],
    %w[引く ひく] => [ # subtraction 減法
      { name: '被減数', particle: 'から' },
      { name: '減数', particle: 'を' },
    ],
    %w[掛ける かける] => [ # multiplication 乗法
      { name: '被乗数', particle: 'に' },
      { name: '乗数', particle: 'を' },
    ],
    %w[割る わる] => [ # division 除法
      { name: '被除数', particle: 'を' },
      { name: '除数', particle: 'で' },
    ],
    # modulus 剰余算
    %w[
      割った余りを求める
      わった余りを求める
      わったあまりを求める
      わったあまりをもとめる
    ] => [
      { name: '被除数', particle: 'を' },
      { name: '除数', particle: 'で' },
    ],

    # TODO: nth power 冪乗
    #       nth root 冪根
  }.freeze

  class << self
    def inject_into(scope)
      BUILT_INS.each do |names, signature|
        names.each do |name|
          scope.add_function name, signature
        end
      end
    end
  end
end
