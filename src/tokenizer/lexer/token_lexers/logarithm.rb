module Tokenizer
  class Lexer
    module TokenLexers
      def logarithm?(chunk)
        %w[対数 たいすう].include? chunk
      end

      # If stack size is 2: base parameter, and argument possessive
      # If stack size is 3: possessive, base parameter, and argument possessive
      def tokenize_logarithm(_chunk)
        argument = @stack.pop
        validate_numeric_parameter argument

        base = @stack.last
        raise Errors::InvalidLogParameterParticle, base.particle unless base.particle == 'を'
        validate_numeric_parameter @stack[-1], @stack[-2]

        # Not actually a "valid" particle as far as Snapdragon is concerned...
        @stack << Token.new(Token::PARAMETER, argument.content, particle: 'の', sub_type: argument.sub_type)
        (@stack << Token.new(Token::LOGARITHM)).last
      end
    end
  end
end
