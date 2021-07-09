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
        valid_argument_types = [Token::VARIABLE, Token::VAR_SORE, Token::VAR_ARE, Token::VAL_NUM]
        raise 'InvalidLogParameter' unless valid_argument_types.include? argument.sub_type 

        base = @stack.last
        raise 'InvalidLogParameterParticle' unless base.particle == 'を'
        validate_loop_parameters @stack[-1], @stack[-2]

        @stack << Token.new(Token::PARAMETER, argument.content, particle: 'の', sub_type: argument.sub_type)
        (@stack << Token.new(Token::LOGARITHM)).last
      end
    end
  end
end

