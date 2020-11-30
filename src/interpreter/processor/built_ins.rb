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
        '追加する'           => 'append',
        '繋ぐ'               => 'concat',
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

      def delegate_built_in(name, args, options = { allow_error?: false, cast_to_boolean?: false })
        begin
          method = FUNCTION_MAP[name]
          @sore = send "process_built_in_#{method}", args
          exit if method == 'dump' && options[:allow_error?]
        rescue Errors::CustomError
          raise
        rescue Errors::BaseError
          raise if options[:allow_error?]
          @sore = nil
        end
        @sore = boolean_cast @sore if options[:cast_to_boolean?]
      end

      # 言葉と 言う / 言葉を 言う
      def process_built_in_print_stdout(args)
        text = resolve_variable! args

        validate_type String, text
        print text
        text
      end

      # メッセージを 表示する
      def process_built_in_display_stdout(args)
        message = resolve_variable! args

        puts Formatter.output message
        message
      end

      # データを ポイ捨てる
      def process_built_in_dump(args)
        data = resolve_variable! args

        Util::Logger.debug Util::Options::DEBUG_3, Formatter.output(data).lblue
        data
      end

      # エラーを 投げる
      def process_built_in_throw(args)
        error_message = resolve_variable! args
        validate_type String, error_message
        STDERR.puts error_message
        raise Errors::CustomError, error_message
      end

      # 対象列に 要素を 追加する
      def process_built_in_append(args)
        target = resolve_variable! args
        element = resolve_variable! args

        case target
        when Array
          target + [element]
        when String
          validate_type String, element
          target + element
        else
          raise Errors::InvalidType.new 'Array or String', Formatter.output(target)
        end
      end

      # 対象列に 要素列を 繋ぐ
      def process_built_in_concat(args)
        target = resolve_variable! args
        source = resolve_variable! args

        validate_type [Array, String], target
        validate_type [Array, String], source
        if source.class != target.class
          raise Errors::MismatchedConcatenation.new(Formatter.output(target), Formatter.output(source))
        end
        target + source
      end

      # 対象列から 要素を 抜く
      def process_built_in_remove(args)
        target_token = args.first
        target = resolve_variable! args
        element = resolve_variable! args

        validate_type [Array, String], target
        if target.is_a?(String) && !element.is_a?(String)
          raise Errors::InvalidType.new 'String', Formatter.output(element)
        end

        index = target.index element
        return nil if index.nil?

        target.slice! index, (element.is_a?(String) ? element.size : 1)
        # TODO: (v1.1.0) Assignment to array
        raise Errors::ExperimentalFeature, 'v1.1.0' if target_token.type == Token::POSSESSIVE
        set_variable target_token, target

        element
      end

      # 対象列から 要素を 全部抜く
      def process_built_in_remove_all(args)
        target_token = args.first
        target = resolve_variable! args
        element = resolve_variable! args

        validate_type [Array, String], target
        if target.is_a?(String) && !element.is_a?(String)
          raise Errors::InvalidType.new 'String', Formatter.output(element)
        end

        elements = []
        loop do
          index = target.index element
          break if index.nil?
          elements << target.slice!(index, (element.respond_to?(:size) ? element.size : 1))
        end

        # TODO: (v1.1.0) Assignment to array
        raise Errors::ExperimentalFeature, 'v1.1.0' if target_token.type == Token::POSSESSIVE
        set_variable target_token, target

        elements.flatten 1
      end

      # 対象列に 要素を 押し込む
      def process_built_in_push(args)
        target_token = args.first
        result = process_built_in_append args

        # TODO: (v1.1.0) Assignment to array
        raise Errors::ExperimentalFeature, 'v1.1.0' if target_token.type == Token::POSSESSIVE
        set_variable target_token, result

        result
      end

      # 対象列から 抜き出す
      def process_built_in_pop(args)
        target_token = args.first
        target = resolve_variable! args

        validate_type [Array, String], target

        element = target[-1]

        # TODO: (v1.1.0) Assignment to array
        raise Errors::ExperimentalFeature, 'v1.1.0' if target_token.type == Token::POSSESSIVE
        set_variable target_token, target[0..-2]

        element
      end

      # 対象列に 要素を 先頭から押し込む
      def process_built_in_unshift(args)
        target_token = args.first
        target = resolve_variable! args
        element = resolve_variable! args

        case target
        when Array
          target = [element] + target
        when String
          validate_type String, element
          target = element + target
        else
          raise Errors::InvalidType.new 'Array or String', Formatter.output(target)
        end

        # TODO: (v1.1.0) Assignment to array
        raise Errors::ExperimentalFeature, 'v1.1.0' if target_token.type == Token::POSSESSIVE
        set_variable target_token, target

        target
      end

      # 対象列から 先頭を抜き出す
      def process_built_in_shift(args)
        target_token = args.first
        target = resolve_variable! args

        validate_type [Array, String], target

        element = target[0]

        # TODO: (v1.1.0) Assignment to array
        raise Errors::ExperimentalFeature, 'v1.1.0' if target_token.type == Token::POSSESSIVE
        set_variable target_token, target.empty? ? target : target[1..-1]

        element
      end

      # 被加数に 加数を 足す
      def process_built_in_add(args)
        a = resolve_variable! args
        b = resolve_variable! args

        validate_type Numeric, a
        validate_type Numeric, b

        a + b
      end

      # 被減数から 減数を 引く
      def process_built_in_subtract(args)
        a = resolve_variable! args
        b = resolve_variable! args

        validate_type Numeric, a
        validate_type Numeric, b

        a - b
      end

      # 被乗数に 乗数を 掛ける
      def process_built_in_multiply(args)
        a = resolve_variable! args
        b = resolve_variable! args

        validate_type Numeric, a
        validate_type Numeric, b

        a * b
      end

      # 被除数を 除数で 割る
      def process_built_in_divide(args)
        a = resolve_variable! args
        b = resolve_variable! args

        validate_type Numeric, a
        validate_type Numeric, b
        raise Errors::DivisionByZero if b.zero?

        a / b
      end

      # 被除数を 除数で 割った余りを求める
      def process_built_in_mod(args)
        a = resolve_variable! args
        b = resolve_variable! args

        validate_type Numeric, a
        validate_type Numeric, b
        raise Errors::DivisionByZero if b.zero?

        a % b
      end
    end
  end
end
