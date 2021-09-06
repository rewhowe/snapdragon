module Interpreter
  class Processor
    module TokenProcessors
      def process_assignment(token)
        value_token = next_token

        case value_token.type
        when Token::RVALUE, Token::POSSESSIVE
          value = resolve_variable! [value_token, next_token_if(Token::PROPERTY)]
          value = boolean_cast value if next_token_if Token::QUESTION
        when Token::ARRAY_BEGIN
          value = process_array_assignment next_tokens_until Token::ARRAY_CLOSE
        end

        # combine with stack in case of possessive
        set_variable @stack + [token], value
        @stack.clear

        @sore = value

        Util::Logger.debug Util::Options::DEBUG_2, "#{token.content} = #{value} (#{value.class})".lpink
      end

      private

      def process_array_assignment(array_tokens)
        array_tokens.pop # discard close
        value = SdArray.new.tap do |elements|
          array_tokens.chunk { |t| t.type == Token::COMMA } .each do |is_comma, chunk|
            next if is_comma

            value = resolve_variable! chunk
            value = boolean_cast value if chunk.last&.type == Token::QUESTION

            elements.push! value
          end
        end
      end
    end
  end
end
