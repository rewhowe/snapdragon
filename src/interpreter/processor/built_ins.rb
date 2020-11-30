require_relative '../../tokenizer/built_ins'
require_relative '../errors'
require_relative '../formatter'

module Interpreter
  class Processor
    module BuiltIns
      def delegate_built_in(name, args, options = { allow_error?: false, cast_to_boolean?: false })
        begin
          @sore = send "process_built_in_#{name.downcase}", args
          exit if name == Tokenizer::BuiltIns::DUMP && options[:allow_error?]
        rescue Errors::CustomError
          raise
        rescue Errors::BaseError
          raise if options[:allow_error?]
          @sore = nil
        end
        @sore = boolean_cast @sore if options[:cast_to_boolean?]
      end

      # 言葉と 言う / 言葉を 言う
      def process_built_in_print(args)
        text = resolve_variable! args

        validate_type String, text
        print text
        text
      end

      # メッセージを 表示する
      def process_built_in_display(args)
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

      # 対象列に 要素列を 繋ぐ
      def process_built_in_concatenate(args)
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
        target = resolve_variable! args
        element = resolve_variable! args

        case target
        when Array
          target += [element]
        when String
          validate_type String, element
          target += element
        else
          raise Errors::InvalidType.new 'Array or String', Formatter.output(target)
        end

        # TODO: (v1.1.0) Assignment to array
        raise Errors::ExperimentalFeature, 'v1.1.0' if target_token.type == Token::POSSESSIVE
        set_variable target_token, target

        target
      end

      # 対象列から 引き出す
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

      # 対象列から 先頭を引き出す
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
      def process_built_in_modulus(args)
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
