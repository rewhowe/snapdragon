module Tokenizer
  class Lexer
    module TokenLexers
      def num_times?(chunk)
        chunk =~ /\A([#{NUMBER}]+)回\z/
      end

      # Shorthand for 1から NUMまで
      def tokenize_num_times(chunk)
        num = Oracles::Value.sanitize chunk.chomp '回'
        (@stack += [
          Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
          Token.new(Token::PARAMETER, num, particle: 'まで', sub_type: Token::VAL_NUM),
        ]).last
      end
    end
  end
end
