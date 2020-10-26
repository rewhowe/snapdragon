module Tokenizer
  class Lexer
    module TokenLexers
      def function_def?(chunk)
        # next_chunk = @reader.peek_next_chunk
        # chunk =~ /.+とは$/ && (eol?(next_chunk) || bang?(next_chunk))
        chunk =~ /.+とは$/
      end

      def process_function_def(chunk)
        raise Errors::UnexpectedFunctionDef, chunk if @context.inside_if_condition?

        validate_scope(
          Scope::TYPE_MAIN,
          ignore: [Scope::TYPE_IF_BLOCK, Scope::TYPE_FUNCTION_DEF], error_class: Errors::UnexpectedFunctionDef
        )

        signature = signature_from_stack
        parameter_names = []

        @stack.each do |token|
          validate_function_def_parameter token, parameter_names

          parameter_names << token.content
        end

        name = chunk.chomp 'とは'
        validate_function_name name, signature

        token = Token.new Token::FUNCTION_DEF, name
        @stack << token

        should_force = bang? @reader.peek_next_chunk
        @current_scope.add_function name, signature, force?: should_force
        begin_scope Scope::TYPE_FUNCTION_DEF
        parameter_names.each { |parameter| @current_scope.add_variable parameter }

        token
      end
    end
  end
end
