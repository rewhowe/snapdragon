module Tokenizer
  class BuiltIns
    private_class_method :new

    BUILT_INS = {
      # Output
      ##########################################################################
      'PRINT' => {
        signature: [{ name: '言葉', particle: 'と' }],
        alternate_signatures: [
          [{ name: '言葉', particle: 'を' }],
        ],
        names: %w[
          言う
          いう
        ],
      },
      'DISPLAY' => {
        signature: [{ name: 'メッセージ', particle: 'を' }],
        names: %w[表示する],
      },
      'DUMP' => {
        signature: [{ name: 'データ', particle: 'を' }],
        names: %w[ポイ捨てる],
      },

      # Formatting
      ##########################################################################
      'FORMAT_STRING' => {
        signature: [
          { name: '文字列', particle: 'に' },
          { name: '引数', particle: 'を' }
        ],
        names: %w[
          書き込む
          書きこむ
          かきこむ
        ],
      },
      'FORMAT_NUMBER' => {
        signature: [
          { name: 'フォーマット文', particle: 'で' },
          { name: '数値', particle: 'を' },
        ],
        names: %w[数値形式にする],
      },
      # 'ROUND' => {
      # },
      # 'CAST_TO_N' => {
      # },
      # 'CAST_TO_I' => {
      # },
      # 'CAST_N_TO_C' => {
      # },

      # String/Array Operations
      ##########################################################################
      'PUSH' => {
        signature: [
          { name: '対象列', particle: 'に' },
          { name: '要素', particle: 'を' },
        ],
        names: %w[
          押し込む
          おしこむ
          追加する
        ],
      },
      'POP' => {
        signature: [
          { name: '対象列', particle: 'から' },
        ],
        names: %w[
          引き出す
          引きだす
          ぬきだす
        ],
      },
      'UNSHIFT' => {
        signature: [
          { name: '対象列', particle: 'に' },
          { name: '要素', particle: 'を' }
        ],
        names: %w[
          先頭から押し込む
          先頭からおしこむ
        ],
      },
      'SHIFT' => {
        signature: [
          { name: '対象列', particle: 'から' },
        ],
        names: %w[
          先頭を引き出す
          先頭を引きだす
          先頭をひきだす
        ],
      },
      'REMOVE' => {
        signature: [
          { name: '対象列', particle: 'から' },
          { name: '要素', particle: 'を' },
        ],
        names: %w[
          抜く
          ぬく
          取る
          とる
        ],
      },
      'REMOVE_ALL' => {
        signature: [
          { name: '対象列', particle: 'から' },
          { name: '要素', particle: 'を' }
        ],
        names: %w[
          全部抜く
          全部ぬく
          全部取る
          全部とる
        ],
      },
      'CONCATENATE' => {
        signature: [
          { name: '対象列', particle: 'に' },
          { name: '要素列', particle: 'を' },
        ],
        names: %w[
          繋ぐ
          つなぐ
          結合する
        ],
      },
      # 'JOIN' => {
      # },
      # 'SPLIT' => {
      # }
      # 'SLICE' => {
      # }
      # 'FIND' => {
      # },
      # 'SORT' => {
      # }

      # Math
      ##########################################################################
      'ADD' => {
        signature: [
          { name: '被加数', particle: 'に' },
          { name: '加数', particle: 'を' },
        ],
        alternate_signatures: [
          [{ name: '加数', particle: 'を' }],
        ],
        names: %w[
          足す
          たす
        ],
      },
      'SUBTRACT' => {
        signature: [
          { name: '被減数', particle: 'から' },
          { name: '減数', particle: 'を' },
        ],
        alternate_signatures: [
          [{ name: '減数', particle: 'を' }],
        ],
        names: %w[
          引く
          ひく
        ],
      },
      'MULTIPLY' => {
        signature: [
          { name: '被乗数', particle: 'に' },
          { name: '乗数', particle: 'を' },
        ],
        alternate_signatures: [
          [{ name: '乗数', particle: 'を' }],
        ],
        names: %w[
          掛ける
          かける
        ],
        conjugations: %w[
          掛けて
          掛けた
          かけて
          かけた
        ],
      },
      'DIVIDE' => {
        signature: [
          { name: '被除数', particle: 'を' },
          { name: '除数', particle: 'で' },
        ],
        alternate_signatures: [
          [{ name: '除数', particle: 'で' }],
        ],
        names: %w[
          割る
          わる
        ],
        conjugations: %w[
          割って
          割った
          わって
          わった
        ],
      },
      'MODULUS' => {
        signature: [
          { name: '被除数', particle: 'を' },
          { name: '除数', particle: 'で' },
        ],
        alternate_signatures: [
          [{ name: '除数', particle: 'で' }],
        ],
        names: %w[
          割った余りを求める
          わった余りを求める
          わったあまりを求める
          わったあまりをもとめる
        ],
        conjugations: %w[
          割った余りを求めて
          割った余りを求めた
          わった余りを求めて
          わった余りを求めた
          わったあまりを求めて
          わったあまりを求めた
          わったあまりをもとめて
          わったあまりをもとめた
        ],
      },

      # Misc
      ##########################################################################
      'THROW' => {
        signature: [{ name: 'エラー', particle: 'を' }],
        names: %w[
          投げる
          なげる
        ],
        conjugations: %w[
          投げて
          投げた
          なげて
          なげた
        ],
      },
      # 'SRAND' => {
      # },
      # 'RAND' => {
      # },
    }.freeze

    BUILT_INS.each_key { |name| const_set(name, name) }

    class << self
      def inject_into(scope)
        BUILT_INS.each do |name, info|
          scope.add_function(
            name,
            info[:signature],
            names: info[:names], built_in?: true, conjugations: info[:conjugations]
          )

          next unless info[:alternate_signatures]

          info[:alternate_signatures].each do |signature|
            scope.add_function(
              name,
              signature,
              names: info[:names], built_in?: true, conjugations: info[:conjugations]
            )
          end
        end
      end

      def math?(name)
        [ADD, SUBTRACT, MULTIPLY, DIVIDE, MODULUS].include? name
      end

      def implicit_math_particle(name)
        built_in = BuiltIns::BUILT_INS[name]
        (built_in[:signature] - built_in[:alternate_signatures]).first[:particle]
      end
    end
  end
end
