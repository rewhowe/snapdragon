require_relative '../errors'
require_relative '../formatter'

module Interpreter
  class Processor
    module BuiltIns
      FUNCTION_MAP = {
        '言う'               => 'print_stdout',
        '表示する'           => 'display_stdout',
        'ポイ捨てる'         => 'dump',
        '投げる'             => 'throw',
        '追加する'           => 'insert',
        '連結する'           => 'concat',
        '抜く'               => 'remove',
        '全部抜く'           => 'remove_all',
        '押し込む'           => 'push',
        '抜き出す'           => 'pop',
        '先頭から押し込む'   => 'unshift',
        '先頭を抜き出す'     => 'shift',
        '足す'               => 'add',
        '引く'               => 'subtract',
        '掛ける'             => 'multiply',
        '割る'               => 'divide',
        '割った余りを求める' => 'mod',
      }.freeze

      def delegate_built_in(name, arguments, is_loud)
        begin
          method = FUNCTION_MAP[name]
          @sore = send "process_built_in_#{method}", *arguments
        rescue => e
          raise e if is_loud
          @sore = nil
        end
      end

      # 言葉と 言う / 言葉を 言う
      def process_built_in_print_stdout(text)
        raise Errors::ExpectedString, Formatter.format_output(text) unless text.is_a? String
        puts text
        text
      end

      # メッセージを 表示する
      def process_built_in_display_stdout
      end

      # データを ポイ捨てる
      def process_built_in_dump
      end

      # エラーを 投げる
      def process_built_in_throw
      end

      # 要素を 対象列に 追加する
      def process_built_in_insert
      end

      # 要素列を 対象列に 連結する
      def process_built_in_concat
      end

      # 対象列から 要素を 抜く
      def process_built_in_remove
      end

      # 対象列から 要素を 全部抜く
      def process_built_in_remove_all
      end

      # 対象列に 要素を 押し込む
      def process_built_in_push
      end

      # 対象列から 抜き出す
      def process_built_in_pop
      end

      # 対象列に 要素を 先頭から押し込む
      def process_built_in_unshift
      end

      # 対象列から 先頭を抜き出す
      def process_built_in_shift
      end

      # 被加数に 加数を 足す
      def process_built_in_add
      end

      # 被減数から 減数を 引く
      def process_built_in_subtract
      end

      # 被乗数に 乗数を 掛ける
      def process_built_in_multiply
      end

      # 被除数を 除数で 割る
      def process_built_in_divide
      end

      # 被除数を 除数で 割った余りを求める
      def process_built_in_mod
      end

    end
  end
end
