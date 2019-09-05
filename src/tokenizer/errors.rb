module Tokenizer
  module Errors
    class LexerError < StandardError
      attr_writer :line_num

      def initialize(message = '')
        super message
      end

      def message
        line_message = @line_num ? "\nAn error occurred while tokenizing on line #{@line_num}" : ''
        puts "#{line_message}\n#{super}".red
      end
    end

    # custom errors

    class UnexpectedIndent < LexerError
      def initialize
        super 'Unexpected indent'
      end
    end

    class UnexpectedInput < LexerError
      def initialize(input)
        super "Unexpected input (#{input})"
      end
    end

    class UnexpectedEof < LexerError
      def initialize
        super 'Unexpected EOF'
      end
    end

    class UnexpectedEol < LexerError
      def initialize
        super 'Unexpected EOL'
      end
    end

    class UnexpectedElseIf < LexerError
      def initialize
        super 'Unexpected else-if'
      end
    end

    class UnexpectedElse < LexerError
      def initialize
        super 'Unexpected else'
      end
    end

    class UnclosedString < LexerError
      def initialize(string)
        super "Unclosed string (#{string})"
      end
    end

    class TrailingCharacters < LexerError
      def initialize(type)
        super "Trailing characters after #{type}"
      end
    end

    class AssignmentToValue < LexerError
      def initialize(value)
        super "Cannot assign to a value (#{value})"
      end
    end

    class FunctionDefDuplicateParameters < LexerError
      def initialize
        super 'Duplicate parameters in function definition'
      end
    end

    class FunctionDefPrimitiveParameters < LexerError
      def initialize
        super 'Cannot declare function using primitives for parameters'
      end
    end

    class FunctionDefNonVerbName < LexerError
      def initialize(name)
        super "Function declaration does not look like a verb (#{name})"
      end
    end

    class FunctionDefAlreadyDeclared < LexerError
      def initialize(name)
        super "Function #{name} has already been declared"
      end
    end
  end
end
