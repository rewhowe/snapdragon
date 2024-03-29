module Tokenizer
  class Lexer
    module TokenLexers
      def function_def?(chunk)
        chunk =~ /.+とは\z/
      end

      def tokenize_function_def(chunk)
        validate_scope(
          Scope::TYPE_MAIN,
          ignore: [Scope::TYPE_IF_BLOCK, Scope::TYPE_FUNCTION_DEF, Scope::TYPE_TRY],
          error_class: Errors::UnexpectedFunctionDef
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

        should_force = bang?(peek_next_chunk_in_seq) || can_overwrite_function_def?
        @current_scope.add_function name, signature, force?: should_force

        begin_scope Scope::TYPE_FUNCTION_DEF
        parameter_names.each { |parameter| @current_scope.add_variable parameter }

        token
      end
    end
  end
end
