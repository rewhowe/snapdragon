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
        (@stack << Token.new(Token::QUESTION)).last
      end
    end
  end
end
