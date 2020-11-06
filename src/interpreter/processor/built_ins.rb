require_relative '../errors'
require_relative '../formatter'

module Interpreter
  class Processor
    module BuiltIns
      FUNCTION_MAP = {
        # rubocop:disable Layout/SpaceAroundOperators
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
        # rubocop:enable Layout/SpaceAroundOperators
      }.freeze

      def delegate_built_in(name, arguments, is_loud)
        method = FUNCTION_MAP[name]
        @sore = send "process_built_in_#{method}", *arguments
        exit if method == 'dump' && is_loud
      rescue Errors::BaseError => e
        raise e if is_loud || e.is_a?(Errors::CustomError)
        @sore = nil
      end

      # 言葉と 言う / 言葉を 言う
      def process_built_in_print_stdout(text)
        raise Errors::ExpectedString, Formatter.output(text) unless text.is_a? String
        print text
        text
      end

      # メッセージを 表示する
      def process_built_in_display_stdout(message)
        puts Formatter.output message
        message
      end

      # データを ポイ捨てる
      def process_built_in_dump(data)
        Util::Logger.debug Util::Options::DEBUG_3, Formatter.output(data).lblue
        data
      end

      # エラーを 投げる
      def process_built_in_throw(error_message)
        raise Errors::ExpectedString, Formatter.output(error_message) unless error_message.is_a? String
        raise Errors::CustomError, error_message
      end

      # 対象列に 要素を 追加する
      def process_built_in_insert(target, element)
        case target.class
        when Array.class
          target + [element]
        when String.class
          raise Errors::ExpectedString, Formatter.output(element) if target.is_a?(String) && !element.is_a?(String)
          target + element
        else
          raise Errors::ExpectedContainer, Formatter.output(target) unless [Array, String].include? target.class
        end
      end

      # 要素列を 対象列に 連結する
      def process_built_in_concat(target, source)
        raise Errors::ExpectedContainer, Formatter.output(target) unless [Array, String].include? target.class
        raise Errors::ExpectedContainer, Formatter.output(target) unless [Array, String].include? source.class
      end

      # 対象列から 要素を 抜く
      def process_built_in_remove(target, element)
        raise Errors::ExpectedContainer, Formatter.output(target) unless [Array, String].include? target.class
        raise Errors::ExpectedString, Formatter.output(element) if target.is_a?(String) && !element.is_a?(String)
      end

      # 対象列から 要素を 全部抜く
      def process_built_in_remove_all(target, element)
        raise Errors::ExpectedContainer, Formatter.output(target) unless [Array, String].include? target.class
        raise Errors::ExpectedString, Formatter.output(element) if target.is_a?(String) && !element.is_a?(String)
      end

      # 対象列に 要素を 押し込む
      def process_built_in_push(target, element)
        raise Errors::ExpectedContainer, Formatter.output(target) unless [Array, String].include? target.class
        raise Errors::ExpectedString, Formatter.output(element) if target.is_a?(String) && !element.is_a?(String)
      end

      # 対象列から 抜き出す
      def process_built_in_pop(target)
        raise Errors::ExpectedContainer, Formatter.output(target) unless [Array, String].include? target.class
      end

      # 対象列に 要素を 先頭から押し込む
      def process_built_in_unshift(target, element)
        raise Errors::ExpectedContainer, Formatter.output(target) unless [Array, String].include? target.class
        raise Errors::ExpectedString, Formatter.output(element) if target.is_a?(String) && !element.is_a?(String)
      end

      # 対象列から 先頭を抜き出す
      def process_built_in_shift(target)
        raise Errors::ExpectedContainer, Formatter.output(target) unless [Array, String].include? target.class
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
