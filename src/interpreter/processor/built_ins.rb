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

      # Output
      ##########################################################################

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

      # Formatting
      ##########################################################################

      # フォーマット文に 引数を 書き込む
      def process_built_in_format_string(args)
        format = resolve_variable! args
        parameters = resolve_variable! args

        validate_type [String], format

        parameters = SdArray.from_array [parameters] unless parameters.is_a? SdArray

        num_parameters = parameters.size

        format = format.gsub(/\\*〇/) do |match|
          # skip escapes
          next match.sub(/^\\/, '') if match.match(/^(\\+)/)&.captures&.first&.length.to_i.odd?

          raise Errors::WrongNumberOfParameters, num_parameters unless parameters.length.nonzero?

          # replace placeholders
          match = match.tr '〇', Formatter.interpolated(parameters.shift!)
          # re-remove double-backslashes (already removed once during string resolution)
          match.gsub(/\\\\/, '\\')
        end

        raise Errors::WrongNumberOfParameters, num_parameters unless parameters.empty?

        format
      end

      # フォーマット文で 数値を 数値形式にする
      def process_built_in_format_number(args)
        format_pattern = /\A(?:(.+?)詰め)?(\d+)桁[.。]?(?:(.+?)詰め)?(?:(\d+)桁)?\z/

        format = resolve_variable! args
        number = resolve_variable! args

        validate_type [String], format
        validate_type [Numeric], number

        raise Errors::InvalidFormat, format unless format =~ format_pattern

        # front_pad, front_digits, back_pad, back_digits
        format_parameters = format_pattern.match(format).captures
        front, back = number.to_f.to_s.split '.'
        format_number_front(front, format_parameters) + format_number_back(back, format_parameters)
      end

      # 数値を 桁数に 四捨五入する
      def process_built_in_round(args)
        digit_pattern = /\A(-?\d+)桁\z/

        number = resolve_variable! args
        digit_format = resolve_variable! args

        validate_type [Numeric], number
        validate_type [String], digit_format

        raise Errors::InvalidFormat, digit_format unless digit_format =~ digit_pattern

        digits = digit_pattern.match(digit_format).captures.first.to_i

        number.round digits
      end

      # 変数を 数値化する
      def process_built_in_cast_to_n(args)
        parameter = resolve_variable! args

        case parameter
        when String
          raise Errors::CastFailure.new parameter, '数値' unless parameter.numeric?
          parameter.to_f
        when Numeric then parameter
        when SdArray then parameter.length
        else parameter ? 1 : 0
        end
      end

      # 変数を 整数化する
      def process_built_in_cast_to_i(args)
        parameter = resolve_variable! args

        case parameter
        when String
          raise Errors::CastFailure.new parameter, '整数' unless parameter.numeric?
          parameter.to_i
        when Numeric then parameter.to_i
        when SdArray then parameter.length
        else parameter ? 1 : 0
        end
      end

      # String / Array Operations
      ##########################################################################

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

      # 要素列を ノリで 連結する
      def process_built_in_join(args)
        elements = resolve_variable! args
        glue = resolve_variable! args

        validate_type [SdArray], elements
        validate_type [String], glue

        elements.values.map { |v| Formatter.interpolated v } .join glue
      end

      # 対象列を 区切り文字で 分割する
      def process_built_in_split(args)
        target = resolve_variable! args
        delimiter = resolve_variable! args

        validate_type [String, SdArray], target

        if target.is_a? String
          validate_type [String], delimiter
          SdArray.from_array target.split delimiter
        else
          SdArray.new.tap do |sa|
            chunk = SdArray.new
            target.values.each do |element|
              if element == delimiter
                sa.push! chunk
                chunk = SdArray.new
              else
                chunk.push! element
              end
            end
            sa.push! chunk
          end
        end
      end

      # 対象列を 始点から 終点まで 切り抜く
      def process_built_in_slice(args)
        target_tokens = target_tokens_from_args args
        target = resolve_variable! args
        start_index = resolve_variable! args
        end_index = resolve_variable! args

        validate_type [String, SdArray], target
        validate_type [Numeric], start_index
        validate_type [Numeric], end_index

        start_index = [start_index, 0].max
        end_index = [end_index, target.length - 1].min

        if start_index > end_index || start_index >= target.length || end_index.negative?
          return target.is_a?(String) ? '' : SdArray.new
        end

        range = start_index..end_index
        slice = target.slice! range

        set_variable target_tokens, target

        slice
      end

      # Math
      ##########################################################################

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

      # Misc
      ##########################################################################

      # エラーを 投げる
      def process_built_in_throw(args)
        error_message = resolve_variable! args
        validate_type [String], error_message
        STDERR.puts error_message
        raise Errors::CustomError, error_message
      end

      private

      def target_tokens_from_args(args)
        target_tokens = [args[0]]
        target_tokens << args[1] if target_tokens.first.type == Token::POSSESSIVE
        target_tokens
      end

      def format_number_front(front, format_parameters)
        front_pad = format_parameters[0] || '0'
        front_digits = format_parameters[1].to_i

        start_index = [front.length - front_digits, 0].max
        front_padding = [front_digits - front.length, 0].max

        (front_pad * front_padding) + front[start_index..-1]
      end

      def format_number_back(back, format_parameters)
        back_pad = format_parameters[2] || '0'
        back_digits = format_parameters[3].to_i

        return '' unless back_digits.positive?

        back = '' if back == '0'

        back_padding = [back_digits - back.length, 0].max
        '.' + back[0..back_digits] + (back_pad * back_padding)
      end
    end
  end
end
