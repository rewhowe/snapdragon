module Interpreter
  class Processor
    module TokenProcessors
      def process_assignment(token)
        # TODO: (v1.1.0) Check for property in the stack
        value_token = next_token

        case value_token.type
        when Token::RVALUE, Token::POSSESSIVE
          value = resolve_variable! [value_token, next_token_if(Token::ATTRIBUTE)]
          value = boolean_cast value if next_token_if Token::QUESTION
        when Token::ARRAY_BEGIN
          value = resolve_array!
        end

        set_variable token, value

        @sore = value

        Util::Logger.debug Util::Options::DEBUG_2, "#{token.content} = #{value} (#{value.class})".lpink
      end
    end
  end
end
