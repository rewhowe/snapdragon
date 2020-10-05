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

    class UnexpectedFunctionDef < LexerError
      def initialize(name)
        super "Unexpected function definition (#{name})"
      end
    end

    class UnexpectedReturn < LexerError
      def initialize(name)
        super 'Expected return'
      end
    end

    class UnexpectedLoop < LexerError
      def initialize
        super 'Unexpected loop'
      end
    end

    class UnexpectedScope < LexerError
      def initialize(expected, actual)
        super "Unexpected scope (expected #{expected}, got #{actual})"
      end
    end

    class UnclosedBlockComment < LexerError
      def initialize
        super 'Unclosed block comment'
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

    class FunctionDefAlreadyDeclared < LexerError
      def initialize(name)
        super "Function #{name} has already been declared"
      end
    end

    class FunctionDefDuplicateParameters < LexerError
      def initialize
        super 'Duplicate parameters in function definition'
      end
    end

    class FunctionDefNonVerbName < LexerError
      def initialize(name)
        super "Function declaration does not look like a verb (#{name})"
      end
    end

    class FunctionDefPrimitiveParameters < LexerError
      def initialize
        super 'Cannot declare function using primitives for parameters'
      end
    end

    class FunctionDefReserved < LexerError
      def initialize(name)
        super "Cannot declare function with reserved name (#{name})"
      end
    end

    class InvalidReturnParameterParticle < LexerError
      def initialize(particle, suggestion)
        super "Invalid return parameter particle (#{particle}). Did you mean '#{suggestion}'?"
      end
    end

    class InvalidReturnParameter < LexerError
      def initialize(name)
        super "Invalid return paramteter (#{name})"
      end
    end

    class InvalidLoopParameter < LexerError
      def initialize(name)
        super "Invalid loop parameter (#{name})"
      end
    end

    class InvalidScope < LexerError
      def intialize(expected)
        super "Invalid scope (expected #{expected})"
      end
    end

    class VariableNameReserved < LexerError
      def initialize(name)
        super "Cannot declare variable with reserved name (#{name})"
      end
    end

    class VariableNameAlreadyDelcaredAsFunction < LexerError
      def initialize(name)
        super "Cannot declare variable with name alreadt declared as function (#{name})"
      end
    end
  end
end
