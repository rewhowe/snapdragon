module Tokenizer
  class Lexer
    module TokenLexers
      def or?(chunk)
        chunk =~ /\A(又|また)は\z/
      end

      def tokenize_or(_chunk)
        comparator_token = last_segment_from_stack[1]
        valid_comparator_tokens = [
          Token::COMP_LT,
          Token::COMP_LTEQ,
          Token::COMP_EQ,
          Token::COMP_NEQ,
          Token::COMP_GTEQ,
          Token::COMP_GT,
        ]
        unless valid_comparator_tokens.include? comparator_token
          @stack.insert last_condition_index_from_stack + 1, Token.new(Token::COMP_EQ)
        end
        (@stack << Token.new(Token::OR)).last
      end
    end
  end
end
