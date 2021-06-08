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
               Token::KEY_SORE  then copy_special @sore
          when Token::VAR_ARE,
               Token::KEY_ARE   then copy_special @are
          when Token::VARIABLE,
               Token::KEY_VAR   then copy_special @current_scope.get_variable token.content
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
        validate_type [String, SdArray], property_owner

        case property_owner
        when String  then resolve_string_property property_owner, property_token
        when SdArray then resolve_array_property property_owner, property_token
        end
      end

      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/CyclomaticComplexity
      def resolve_string_property(property_owner, property_token)
        case property_token.sub_type
        when Token::PROP_LEN        then property_owner.length
        when Token::PROP_KEYS       then raise Errors::InvalidStringProperty, property_token.content
        when Token::PROP_FIRST      then property_owner[0] || ''
        when Token::PROP_LAST       then property_owner[-1] || ''
        when Token::PROP_FIRST_IGAI then property_owner[1..-1] || ''
        when Token::PROP_LAST_IGAI  then property_owner[0..-2] || ''
        else # Token::KEY_INDEX, Token::KEY_NAME, Token::KEY_VAR, Token::KEY_SORE, Token::KEY_ARE
          index = resolve_variable! [property_token]
          return nil unless valid_string_index? property_owner, index
          property_owner[index.to_i]
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
        else # Token::KEY_NAME, Token::KEY_VAR, Token::KEY_SORE, Token::KEY_ARE
          property_owner.get resolve_variable! [property_token]
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end
