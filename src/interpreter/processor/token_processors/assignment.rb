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
          value = resolve_array!
        end

        # combine with stack in case of possessive
        set_variable @stack + [token], value
        @stack.clear

        @sore = value

        Util::Logger.debug Util::Options::DEBUG_2, "#{token.content} = #{value} (#{value.class})".lpink
      end
    end
  end
end
