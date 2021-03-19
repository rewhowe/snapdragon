require_relative '../../tokenizer/built_ins'
require_relative '../errors'
require_relative '../formatter'
require_relative '../sd_array'

module Interpreter
  class Processor
    module BuiltIns
      def delegate_built_in(name, args, options = { suppress_error?: false, cast_to_boolean?: false })
        begin
          @sore = send "process_built_in_#{name.downcase}", args
          # Special case: quit on dump with bang
          exit if name == Tokenizer::BuiltIns::DUMP && options[:suppress_error?]
        rescue Errors::CustomError
          raise
        rescue Errors::BaseError
          raise unless options[:suppress_error?]
          @sore = nil
        end
        @sore = boolean_cast @sore if options[:cast_to_boolean?]
      end

      # 言葉と 言う / 言葉を 言う
      def process_built_in_print(args)
        text = resolve_variable! args

        validate_type [String], text
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
        validate_type [String], error_message
        STDERR.puts error_message
        raise Errors::CustomError, error_message
      end

      # 対象列に 要素列を 繋ぐ
      def process_built_in_concatenate(args)
        target = resolve_variable! args
        source = resolve_variable! args

        validate_type [String, SdArray], target
        validate_type [String, SdArray], source
        if source.class != target.class
          raise Errors::MismatchedConcatenation.new(Formatter.output(target), Formatter.output(source))
        end

        target.is_a?(String) ? target + source : target.concat!(source)
      end

      # 対象列から 要素を 抜く
      def process_built_in_remove(args)
        target_tokens = target_tokens_from_args args
        target = resolve_variable! args
        element = resolve_variable! args

        validate_type [String, SdArray], target

        if target.is_a? String
          validate_type [String], element

          return nil unless target.sub! element, ''
        else
          return nil unless target.remove! element
        end

        set_variable target_tokens, target

        element
      end

      # 対象列から 要素を 全部抜く
      def process_built_in_remove_all(args)
        target_tokens = target_tokens_from_args args
        target = resolve_variable! args
        element = resolve_variable! args

        validate_type [String, SdArray], target

        elements = []
        if target.is_a? String
          validate_type [String], element
          target = target.gsub(/#{element}/) do |match|
            elements << match
            ''
          end
        else
          elements = target.remove_all! element
        end

        set_variable target_tokens, target

        elements
      end

      # 対象列に 要素を 押し込む
      def process_built_in_push(args)
        target_tokens = target_tokens_from_args args
        target = resolve_variable! args
        element = resolve_variable! args

        validate_type [String, SdArray], target

        if target.is_a? String
          validate_type [String], element
          target += element
        else
          target.push! element
        end

        set_variable target_tokens, target

        target
      end

      # 対象列から 引き出す
      def process_built_in_pop(args)
        target_tokens = target_tokens_from_args args
        target = resolve_variable! args

        validate_type [String, SdArray], target

        if target.is_a? String
          element = target[-1]
          target = target[0..-2]
        else
          element = target.pop!
        end

        set_variable target_tokens, target

        element
      end

      # 対象列に 要素を 先頭から押し込む
      def process_built_in_unshift(args)
        target_tokens = target_tokens_from_args args
        target = resolve_variable! args
        element = resolve_variable! args

        validate_type [String, SdArray], target

        if target.is_a? String
          validate_type [String], element
          target = element + target
        else
          target.unshift! element
        end

        set_variable target_tokens, target

        target
      end

      # 対象列から 先頭を引き出す
      def process_built_in_shift(args)
        target_tokens = target_tokens_from_args args
        target = resolve_variable! args

        validate_type [String, SdArray], target

        if target.is_a? String
          element = target[0]
          target = target.empty? ? target : target[1..-1]
        else
          element = target.shift!
        end

        set_variable target_tokens, target

        element
      end

      # 被加数に 加数を 足す
      def process_built_in_add(args)
        a = resolve_variable! args
        b = resolve_variable! args

        validate_type [Numeric], a
        validate_type [Numeric], b

        a + b
      end

      # 被減数から 減数を 引く
      def process_built_in_subtract(args)
        a = resolve_variable! args
        b = resolve_variable! args

        validate_type [Numeric], a
        validate_type [Numeric], b

        a - b
      end

      # 被乗数に 乗数を 掛ける
      def process_built_in_multiply(args)
        a = resolve_variable! args
        b = resolve_variable! args

        validate_type [Numeric], a
        validate_type [Numeric], b

        a * b
      end

      # 被除数を 除数で 割る
      def process_built_in_divide(args)
        a = resolve_variable! args
        b = resolve_variable! args

        validate_type [Numeric], a
        validate_type [Numeric], b
        raise Errors::DivisionByZero if b.zero?

        a / b
      end

      # 被除数を 除数で 割った余りを求める
      def process_built_in_modulus(args)
        a = resolve_variable! args
        b = resolve_variable! args

        validate_type [Numeric], a
        validate_type [Numeric], b
        raise Errors::DivisionByZero if b.zero?

        a % b
      end

      private

      def target_tokens_from_args(args)
        target_tokens = [args[0]]
        target_tokens << args[1] if target_tokens.first.type == Token::POSSESSIVE
        target_tokens
      end
    end
  end
end
