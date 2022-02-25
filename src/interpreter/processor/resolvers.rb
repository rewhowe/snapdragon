module Interpreter
  class Processor
    module Resolvers
      # rubocop:disable Metrics/CyclomaticComplexity
      def resolve_variable!(tokens)
        token = tokens.shift

        value = begin
          case token.sub_type
          when Token::VAL_NUM   then token.content.to_f
          when Token::KEY_INDEX then token.content.to_f - 1
          when Token::VAL_STR,
               Token::KEY_NAME  then resolve_string token.content
          when Token::VAL_TRUE  then true
          when Token::VAL_FALSE then false
          when Token::VAL_NULL  then nil
          when Token::VAL_ARRAY then SdArray.new
          when Token::VAR_SORE,
               Token::KEY_SORE  then @sore
          when Token::VAR_ARE,
               Token::KEY_ARE   then @are
          when Token::VARIABLE,
               Token::KEY_VAR   then @current_scope.get_variable token.content
          end
        end

        return resolve_property value, tokens.shift if token.type == Token::POSSESSIVE

        value
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def resolve_string(value)
        # Remove opening / closing quotes
        value = value.gsub(/^「/, '').gsub(/」$/, '')

        # Escape closing quotes
        value = value.gsub(/\\」/, '」')

        # Check for string interpolation and pass substitutions back to lexer
        value = resolve_string_interpolation value

        # Handling even/odd backslashes is too messy in regex: brute-force
        value = value.gsub(/(\\*n)/) { |match| match.length.even? ? match.gsub(/\\n/, "\n") : match  }
        value = value.gsub(/(\\*￥ｎ)/) { |match| match.length.even? ? match.gsub(/￥ｎ/, "\n") : match  }

        # Finally remove additional double-backslashes
        value.gsub(/\\\\/, '\\')
      end

      def resolve_string_interpolation(value)
        value.gsub(/\\*【[^】]*】?/) do |match|
          # skip escapes
          next match.sub(/^\\/, '') if match.match(/^(\\+)/)&.captures&.first&.length.to_i.odd?

          interpolation_tokens = @lexer.interpolate_string match

          validate_interpolation_tokens interpolation_tokens

          Formatter.interpolated resolve_variable! interpolation_tokens
        end
      end

      ##
      # SEE: src/tokenizer/oracles/property.rb for valid property owners
      def resolve_property(property_owner, property_token)
        validate_type [String, SdArray, Numeric], property_owner

        case property_owner
        when String  then resolve_string_property property_owner, property_token
        when SdArray then resolve_array_property property_owner, property_token
        when Numeric then resolve_numeric_property property_owner, property_token
        end
      end

      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/CyclomaticComplexity
      def resolve_string_property(property_owner, property_token)
        case property_token.sub_type
        when Token::PROP_LEN        then property_owner.length
        when Token::PROP_FIRST      then property_owner[0] || ''
        when Token::PROP_LAST       then property_owner[-1] || ''
        when Token::PROP_FIRST_IGAI then property_owner[1..-1] || ''
        when Token::PROP_LAST_IGAI  then property_owner[0..-2] || ''
        when Token::KEY_INDEX, Token::KEY_NAME, Token::KEY_VAR, Token::KEY_SORE, Token::KEY_ARE
          index = resolve_variable! [property_token]
          return nil unless valid_string_index? property_owner, index
          property_owner[index.to_i]
        else
          # Token::PROP_KEYS,
          # Token::PROP_EXP, Token::PROP_EXP_SORE, Token::PROP_EXP_ARE,
          # Token::PROP_ROOT, Token::PROP_ROOT_SORE, Token::PROP_ROOT_ARE,
          raise Errors::InvalidStringProperty, property_token.content
        end
      end
      # rubocop:enable Metrics/PerceivedComplexity

      def resolve_array_property(property_owner, property_token)
        case property_token.sub_type
        when Token::PROP_LEN        then property_owner.length
        when Token::PROP_KEYS       then property_owner.formatted_keys
        when Token::PROP_FIRST      then property_owner.first
        when Token::PROP_LAST       then property_owner.last
        when Token::PROP_FIRST_IGAI then property_owner.range 1..-1
        when Token::PROP_LAST_IGAI  then property_owner.range 0..-2
        when Token::KEY_INDEX       then property_owner.get_at resolve_variable! [property_token]
        when Token::KEY_NAME, Token::KEY_VAR, Token::KEY_SORE, Token::KEY_ARE
          property_owner.get resolve_variable! [property_token]
        else
          # Token::PROP_EXP, Token::PROP_EXP_SORE, Token::PROP_EXP_ARE,
          # Token::PROP_ROOT, Token::PROP_ROOT_SORE, Token::PROP_ROOT_ARE,
          raise Errors::InvalidArrayProperty, property_token.content
        end
      end

      def resolve_numeric_property(property_owner, property_token)
        case property_token.sub_type
        when Token::PROP_EXP then property_owner**property_token.content.to_f
        when Token::PROP_EXP_SORE
          validate_type [Numeric], @sore
          property_owner**@sore
        when Token::PROP_EXP_ARE
          validate_type [Numeric], @are
          property_owner**@are
        when Token::PROP_ROOT
          calculate_root property_owner, property_token.content.to_f
        when Token::PROP_ROOT_SORE
          validate_type [Numeric], @sore
          calculate_root property_owner, @sore
        when Token::PROP_ROOT_ARE
          validate_type [Numeric], @are
          calculate_root property_owner, @are
        else
          # Token::PROP_LEN, Token::PROP_KEYS,
          # Token::PROP_FIRST, Token::PROP_LAST, Token::PROP_FIRST_IGAI, Token::PROP_LAST_IGAI,
          # Token::KEY_INDEX, Token::KEY_NAME, Token::KEY_VAR, Token::KEY_SORE, Token::KEY_ARE,
          raise Errors::InvalidNumericProperty, property_token.content
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def resolve_parameters_from_stack!
        [].tap { |a| a << resolve_variable!(@stack) until @stack.empty? }
      end

      private

      # Returns the square root if nth_root is 2
      # Returns the cube root if nth_root is 3
      # Otherwise, calculates the nth root by raising to a fractional power
      # QoL note: returns the rounded root if it gives the original number when
      # raised to the same power
      def calculate_root(number, nth_root)
        case nth_root.to_f
        when 2.0 then Math.sqrt number
        when 3.0 then Math.cbrt number
        else
          root = number**(1 / nth_root.to_f)
          return root.round if root.round**nth_root == number
          root
        end
      end
    end
  end
end
