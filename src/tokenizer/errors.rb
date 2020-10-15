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

    class UnexpectedComparison < LexerError
      def initialize
        super "Unexpected comparison. Did you forget 'もし'?"
      end
    end

    class UnexpectedFunctionDef < LexerError
      def initialize(name)
        super "Unexpected function definition (#{name})"
      end
    end

    class UnexpectedFunctionCall < LexerError
      def initialize(name)
        super "Unexpected function call (#{name})"
      end
    end

    class UnexpectedReturn < LexerError
      def initialize(name)
        super "Expected return (#{name})"
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

    class FunctionDefAmbiguousConjugation < LexerError
      def initialize(name, existing_name)
        super "Function #{name} has conjugations which conflict with previously declared function #{existing_name}.\n" \
          'Use ! or ！ after the function definition to override previous conjugations.'
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

    class InvalidLoopParameter < LexerError
      def initialize(name)
        super "Invalid loop parameter (#{name})"
      end
    end

    class InvalidLoopParameterParticle < LexerError
      def initialize(particle)
        super "Invalid loop parameter particle (#{particle})"
      end
    end

    class InvalidPropertyOwner < LexerError
      def initialize(name)
        super "Invalid property owner (#{name})"
      end
    end

    class InvalidFunctionDefParameter < LexerError
      def initialize(name)
        super "Invalid function definition parameter (#{name})"
      end
    end

    class InvalidPropertyComparison < LexerError
      def initialize(property, next_chunk)
        super "Invalid property comparison (near: '#{property} #{next_chunk}')"
      end
    end

    class InvalidStringAttribute < LexerError
      def initialize(attribute)
        super "Invalid string attribute (#{attribute})"
      end
    end

    class VariableNameReserved < LexerError
      def initialize(name)
        super "Cannot declare variable with reserved name (#{name})"
      end
    end

    class VariableNameAlreadyDelcaredAsFunction < LexerError
      def initialize(name)
        super "Cannot declare variable with name already declared as function (#{name})"
      end
    end

    class VariableDoesNotExist < LexerError
      def initialize(name)
        super "Variable does not exist (#{name})"
      end
    end

    class AttributeDoesNotExist < LexerError
      def initialize(name)
        super "Attribute does not exist (#{name})"
      end
    end

    class ExperimentalFeature < LexerError
      def initialize(name)
        super "This feature is not yet supported (#{name})"
      end
    end

    class AccessOfSelfAsAttribute < LexerError
      def initialize(attribute)
        super "Cannot access attribute with same name as property owner (#{attribute})."
      end
    end

    class MultipleAssignment < LexerError
      def initialize(name)
        super "Assignment found within assignment (#{name})"
      end
    end
  end
end
