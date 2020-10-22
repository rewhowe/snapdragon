module Tokenizer
  class Lexer
    module TokenLexers
      def question?(chunk)
        chunk =~ /^[#{QUESTION}]$/
      end

      # TODO: (v1.1.0)
      # Unless stack is empty? and peek next token is not comp_3*
      #   validate_logical_operation
      #   format logic operation (just slip comarison token in before comparators)
      def process_question(_chunk)
        token = Token.new Token::QUESTION
        if @context.inside_assignment?
          @stack << token
          try_assignment_close
        elsif @context.inside_if_condition?
          @stack << token
        else # Must be function call
          raise Errors::UnexpectedQuestion, @stack.last.content unless @stack.empty?
          @tokens << token
        end
        token
      end
    end
  end
end
