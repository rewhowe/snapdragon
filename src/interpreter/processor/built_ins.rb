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

      def delegate_built_in(name, args, is_loud)
        method = FUNCTION_MAP[name]
        @sore = send "process_built_in_#{method}", args
        exit if method == 'dump' && is_loud
      rescue Errors::BaseError => e
        raise e if is_loud || e.is_a?(Errors::CustomError)
        @sore = nil
      end

      # 言葉と 言う / 言葉を 言う
      def process_built_in_print_stdout(args)
        # TODO: feature/properties
        text = resolve_variable args[0]

        raise Errors::ExpectedString, Formatter.output(text) unless text.is_a? String
        print text
        text
      end

      # メッセージを 表示する
      def process_built_in_display_stdout(args)
        # TODO: feature/properties
        message = resolve_variable args[0]

        puts Formatter.output message
        message
      end

      # データを ポイ捨てる
      def process_built_in_dump(args)
        # TODO: feature/properties
        data = resolve_variable args[0]

        Util::Logger.debug Util::Options::DEBUG_3, Formatter.output(data).lblue
        data
      end

      # エラーを 投げる
      def process_built_in_throw(args)
        # TODO: feature/properties
        error_message = args[0]
        raise Errors::ExpectedString, Formatter.output(error_message) unless error_message.is_a? String
        raise Errors::CustomError, error_message
      end

      # 対象列に 要素を 追加する
      def process_built_in_insert(args)
        # TODO: feature/properties
        target = resolve_variable args[0]
        element = resolve_variable args[1]

        case target
        when Array
          puts target.class
          target + [element]
        when String
          raise Errors::ExpectedString, Formatter.output(element) if target.is_a?(String) && !element.is_a?(String)
          target + element
        else
          raise Errors::ExpectedContainer, Formatter.output(target)
        end
      end

      # 対象列に 要素列を 連結する
      def process_built_in_concat(args)
        # TODO: feature/properties
        source = resolve_variable args[1]
        target = resolve_variable args[0]

        raise Errors::ExpectedContainer, Formatter.output(target) unless [Array, String].include? source.class
        raise Errors::ExpectedContainer, Formatter.output(target) unless [Array, String].include? target.class
        if source.class != target.class
          raise Errors::MismatchedConcatenation.new(Formatter.output(target), Formatter.output(source))
        end
        target + source
      end

      # 対象列から 要素を 抜く
      def process_built_in_remove(args)
        # TODO: feature/properties
        target = resolve_variable args[0]
        element = resolve_variable args[1]

        raise Errors::ExpectedContainer, Formatter.output(target) unless [Array, String].include? target.class
        raise Errors::ExpectedString, Formatter.output(element) if target.is_a?(String) && !element.is_a?(String)

        index = target.index element
        return nil if index.nil?

        target.slice! index, (element.respond_to?(:size) ? element.size : 1)
        # TODO: feature/properties
        @current_scope.set_variable args[0].content, target

        element
      end

      # 対象列から 要素を 全部抜く
      def process_built_in_remove_all(args)
        # TODO: feature/properties
        target = resolve_variable args[0]
        element = resolve_variable args[1]

        raise Errors::ExpectedContainer, Formatter.output(target) unless [Array, String].include? target.class
        raise Errors::ExpectedString, Formatter.output(element) if target.is_a?(String) && !element.is_a?(String)

        elements = []
        loop do
          index = target.index element
          break if index.nil?
          elements << target.slice!(index, (element.respond_to?(:size) ? element.size : 1))
        end

        # TODO: feature/properties
        @current_scope.set_variable args[0].content, target

        elements
      end

      # 対象列に 要素を 押し込む
      def process_built_in_push(args)
        result = process_built_in_insert args

        # TODO: feature/properties
        @current_scope.set_variable args[0].content, result

        result
      end

      # 対象列から 抜き出す
      def process_built_in_pop(args)
        # TODO: feature/properties
        target = resolve_variable args[0]

        raise Errors::ExpectedContainer, Formatter.output(target) unless [Array, String].include? target.class

        element = target[-1]

        # TODO: feature/properties
        @current_scope.set_variable args[0].content, target[0..-2]

        element
      end

      # 対象列に 要素を 先頭から押し込む
      def process_built_in_unshift(args)
        # TODO: feature/properties
        target = resolve_variable args[0]
        element = resolve_variable args[1]

        case target
        when Array
          target = [element] + target
        when String
          raise Errors::ExpectedString, Formatter.output(element) if target.is_a?(String) && !element.is_a?(String)
          target = element + target
        else
          raise Errors::ExpectedContainer, Formatter.output(target)
        end

        # TODO: feature/properties
        @current_scope.set_variable args[0].content, target
        target
      end

      # 対象列から 先頭を抜き出す
      def process_built_in_shift(args)
        # TODO: feature/properties
        target = resolve_variable args[0]

        raise Errors::ExpectedContainer, Formatter.output(target) unless [Array, String].include? target.class

        element = target[0]

        # TODO: feature/properties
        @current_scope.set_variable args[0].content, target.empty? ? target : target[1..-1]

        element
      end

      # 被加数に 加数を 足す
      def process_built_in_add(args)
        # TODO: feature/properties
        a = resolve_variable args[0]
        b = resolve_variable args[1]

        raise Errors::ExpectedNumber, Formatter.output(a) unless a.is_a? Numeric
        raise Errors::ExpectedNumber, Formatter.output(b) unless b.is_a? Numeric

        a + b
      end

      # 被減数から 減数を 引く
      def process_built_in_subtract(args)
        # TODO: feature/properties
        a = resolve_variable args[0]
        b = resolve_variable args[1]

        raise Errors::ExpectedNumber, Formatter.output(a) unless a.is_a? Numeric
        raise Errors::ExpectedNumber, Formatter.output(b) unless b.is_a? Numeric

        a - b
      end

      # 被乗数に 乗数を 掛ける
      def process_built_in_multiply(args)
        # TODO: feature/properties
        a = resolve_variable args[0]
        b = resolve_variable args[1]

        raise Errors::ExpectedNumber, Formatter.output(a) unless a.is_a? Numeric
        raise Errors::ExpectedNumber, Formatter.output(b) unless b.is_a? Numeric

        a * b
      end

      # 被除数を 除数で 割る
      def process_built_in_divide(args)
        # TODO: feature/properties
        a = resolve_variable args[0]
        b = resolve_variable args[1]

        raise Errors::ExpectedNumber, Formatter.output(a) unless a.is_a? Numeric
        raise Errors::ExpectedNumber, Formatter.output(b) unless b.is_a? Numeric
        raise Errors::DivisionByZero if b.zero?

        a / b
      end

      # 被除数を 除数で 割った余りを求める
      def process_built_in_mod(args)
        # TODO: feature/properties
        a = resolve_variable args[0]
        b = resolve_variable args[1]

        raise Errors::ExpectedNumber, Formatter.output(a) unless a.is_a? Numeric
        raise Errors::ExpectedNumber, Formatter.output(b) unless b.is_a? Numeric

        a % b
      end
    end
  end
end
