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
        conjugations: %w[
          ポイ捨てて
          ポイ捨てた
        ],
      },

      # Formatting
      ##########################################################################
      'FORMAT' => {
        signature: [
          { name: '文字列', particle: 'に' },
          { name: '引数', particle: 'を' },
        ],
        names: %w[記入する],
      },
      'ROUND_UP' => {
        signature: [
          { name: '数値', particle: 'を' },
          { name: '精度', particle: 'に' },
        ],
        names: %w[
          切り上げる
          きりあげる
        ],
        conjugations: %w[
          切り上げて
          切り上げた
          きりあげて
          きりあげた
        ],
      },
      'ROUND_DOWN' => {
        signature: [
          { name: '数値', particle: 'を' },
          { name: '精度', particle: 'に' },
        ],
        names: %w[
          切り下げる
          きりさげる
        ],
        conjugations: %w[
          切り下げて
          切り下げた
          きりさげて
          きりさげた
        ],
      },
      'ROUND_NEAREST' => {
        signature: [
          { name: '数値', particle: 'を' },
          { name: '精度', particle: 'に' },
        ],
        names: %w[
          切り捨てる
          きりすてる
        ],
        conjugations: %w[
          切り捨てて
          切り捨てた
          きりすてて
          きりすてた
        ],
      },
      'CAST_TO_N' => {
        signature: [
          { name: '変数', particle: 'を' },
        ],
        names: %w[数値化する],
      },
      'CAST_TO_I' => {
        signature: [
          { name: '変数', particle: 'を' },
        ],
        names: %w[整数化する],
      },

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
          { name: '要素', particle: 'を' },
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
        conjugations: %w[
          抜いて
          抜いた
          ぬいて
          ぬいた
          取って
          取った
          とって
          とった
        ],
      },
      'REMOVE_ALL' => {
        signature: [
          { name: '対象列', particle: 'から' },
          { name: '要素', particle: 'を' },
        ],
        names: %w[
          全部抜く
          全部ぬく
          全部取る
          全部とる
        ],
        conjugations: %w[
          全部抜いて
          全部抜いた
          全部ぬいて
          全部ぬいた
          全部取って
          全部取った
          全部とって
          全部とった
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
      'JOIN' => {
        signature: [
          { name: '要素列', particle: 'を' },
          { name: 'ノリ', particle: 'で' },
        ],
        names: %w[連結する],
      },
      'SPLIT' => {
        signature: [
          { name: '対象列', particle: 'を' },
          { name: '区切り', particle: 'で' },
        ],
        names: %w[分割する],
      },
      'SLICE' => {
        signature: [
          { name: '対象列', particle: 'を' },
          { name: '始点', particle: 'から' },
          { name: '終点', particle: 'まで' },
        ],
        names: %w[
          切り抜く
          切りぬく
          きりぬく
        ],
      },
      'FIND' => {
        signature: [
          { name: '対象列', particle: 'で' },
          { name: '要素', particle: 'を' },
        ],
        names: %w[
          探す
          さがす
        ],
      },
      'SORT' => {
        signature: [
          { name: '要素列', particle: 'を' },
          { name: '並び順', particle: 'で' },
        ],
        names: %w[
          並び替える
          ならびかえる
        ],
        conjugations: %w[
          並び替えて
          並び替えた
          ならびかえて
          ならびかえた
        ],
      },

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

      # File IO
      ##########################################################################
      # TODO: (feature/file-io)

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
      'SRAND' => {
        signature: [
          { name: '値', particle: 'を' },
        ],
        names: %w[乱数の種に与える],
        conjugations: %w[
          乱数の種に与えて
          乱数の種に与えた
        ],
      },
      'RAND' => {
        signature: [
          { name: '最低値', particle: 'から' },
          { name: '最大値', particle: 'まで' },
        ],
        names: %w[の乱数を発生させる],
        conjugations: %w[
          の乱数を発生させて
          の乱数を発生させた
        ],
      },
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
