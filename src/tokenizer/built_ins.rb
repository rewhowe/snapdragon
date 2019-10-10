# TODO: during compilation, use macros/inlines instead of actual function calls
module Tokenizer
  module BuiltIns
    BUILT_INS = {
      '言う' => { # printf / print / console.log / etc
        signature: [{ name: '言葉', particle: 'と' }],
        alternate_signatures: [
          [{ name: '言葉', particle: 'を' }],
        ],
        aliases: %w[いう],
      },
      'ログする' => { # output to log / console.log / etc
        signature: [{ name: 'メッセージ', particle: 'を' }],
      },
      '表示する' => { # std out / print / alert / etc
        signature: [{ name: 'メッセージ', particle: 'を' }],
      },
      '投げる' => { # std err / raise / alert / etc
        signature: [{ name: 'エラー', particle: 'を' }],
        aliases: %w[なげる],
      },
      '押し込む' => { # push
        signature: [
          { name: '対象列', particle: 'に' },
          { name: '要素', particle: 'を' },
        ],
        aliases: %w[おしこむ],
      },
      '抜き出す' => { # pop
        signature: [
          { name: '対象列', particle: 'から' },
        ],
        aliases: %w[
          抜きだす
          ぬきだす
        ],
      },
      '先頭から押し込む' => { # unshift
        signature: [
          { name: '対象列', particle: 'に' },
          { name: '要素', particle: 'を' }
        ],
        aliases: %w[
          先頭からおしこむ
          せんとうからおしこむ
        ],
      },
      '先頭を抜き出す' => { # shift
        signature: [
          { name: '対象列', particle: 'から' },
        ],
        aliases: %w[
          先頭を抜きだす
          先頭をぬきだす
          せんとうをぬきだす
        ],
      },
      '追加する' => { # append
        signature: [
          { name: '対象列', particle: 'に' },
          { name: '要素', particle: 'を' },
        ],
      },
      '連結する' => { # concatenate
        signature: [
          { name: '対象列', particle: 'に' },
          { name: '要素列', particle: 'を' },
        ],
      },
      '抜く' => { # remove first from array / string
        signature: [
          { name: '対象列', particle: 'から' },
          { name: '要素', particle: 'を' },
        ],
        aliases: %w[ぬく],
      },
      '全部抜く' => { # remove all from array / string
        signature: [
          { name: '対象列', particle: 'から' },
          { name: '要素', particle: 'を' }
        ],
        aliases: %w[全部ぬく],
      },
      '足す' => { # addition 加法
        signature: [
          { name: '被加数', particle: 'に' },
          { name: '加数', particle: 'を' },
        ],
        alternate_signatures: [
          [{ name: '加数', particle: 'を' }],
        ],
        aliases: %w[たす],
      },
      '引く' => { # subtraction 減法
        signature: [
          { name: '被減数', particle: 'から' },
          { name: '減数', particle: 'を' },
        ],
        alternate_signatures: [
          [{ name: '減数', particle: 'を' }],
        ],
        aliases: %w[ひく],
      },
      '掛ける' => { # multiplication 乗法
        signature: [
          { name: '被乗数', particle: 'に' },
          { name: '乗数', particle: 'を' },
        ],
        alternate_signatures: [
          [{ name: '乗数', particle: 'を' }],
        ],
        aliases: %w[かける],
      },
      '割る' => { # division 除法
        signature: [
          { name: '被除数', particle: 'を' },
          { name: '除数', particle: 'で' },
        ],
        alternate_signatures: [
          [{ name: '除数', particle: 'で' }],
        ],
        aliases: %w[わる],
      },
      '割った余りを求める' => { # modulus 剰余算
        signature: [
          { name: '被除数', particle: 'を' },
          { name: '除数', particle: 'で' },
        ],
        alternate_signatures: [
          [{ name: '除数', particle: 'で' }],
        ],
        aliases: %w[
          わった余りを求める
          わったあまりを求める
          わったあまりをもとめる
        ],
      },

      # TODO: additional math functions cannot be constructed as verbs... must use custom keywords
      #   nth power 冪乗
      #     ([変数|値]は) [変数|値]の [変数|値]乗
      #     ASSIGNMENT POSSESSION EXPONENT
      #   nth root 冪根
      #     ([変数|値]は) [変数|値]の [変数|値]乗根
      #     ASSIGNMENT POSSESSION ROOT
      #   log n
      #     ([変数|値]は) 底を [変数|値]とする [変数|値]の対数
      #     ASSIGNMENT LOG_1 LOG_2 LOG_3
    }.freeze

    class << self
      def inject_into(scope)
        BUILT_INS.each do |name, info|
          scope.add_function name, info[:signature], aliases: info[:aliases]

          next unless info[:alternate_signatures]

          info[:alternate_signatures].each do |signature|
            scope.add_function name, signature, alias_of: name, aliases: info[:aliases]
          end
        end
      end
    end
  end
end
