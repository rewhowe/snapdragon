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

    CUSTOM_ERRORS = {
      'UnexpectedIndent'                      => 'Unexpected indent',
      'UnexpectedInput'                       => 'Unexpected input (%s)',
      'UnexpectedEof'                         => 'Unexpected EOF',
      'UnexpectedEol'                         => 'Unexpected EOL',
      'UnexpectedElseIf'                      => 'Unexpected else-if',
      'UnexpectedElse'                        => 'Unexpected else',
      'UnexpectedComparison'                  => "Unexpected comparison. Did you forget 'もし'?",
      'UnexpectedFunctionDef'                 => 'Unexpected function definition (%s)',
      'UnexpectedFunctionCall'                => 'Unexpected function call (%s)',
      'UnexpectedReturn'                      => 'Expected return (%s)',
      'UnexpectedLoop'                        => 'Unexpected loop',
      'UnexpectedScope'                       => 'Unexpected scope (expected %s, got %s)',
      'UnclosedBlockComment'                  => 'Unclosed block comment',
      'UnclosedString'                        => 'Unclosed string (%s)',
      'TrailingCharacters'                    => 'Trailing characters after %s',
      'AssignmentToValue'                     => 'Cannot assign to a value (%s)',
      'FunctionDefAlreadyDeclared'            => 'Function %s has already been declared',
      'FunctionDefAmbiguousConjugation'       => 'Function %s has conjugations which conlict with previously declared' \
                                                 ' function %s. Use ! or ！ after the function definition to override' \
                                                 ' previous conjugations.',
      'FunctionDefDuplicateParameters'        => 'Duplicate parameters in function definition',
      'FunctionDefNonVerbName'                => 'Function declaration does not look like a verb (%s)',
      'FunctionDefPrimitiveParameters'        => 'Cannot declare function using primitives for parameters',
      'FunctionDefReserved'                   => 'Cannot declare function with reserved name (%s)',
      'InvalidReturnParameterParticle'        => "Invalid return parameter particle (%s). Did you mean '%s'?",
      'InvalidLoopParameter'                  => 'Invalid loop parameter (%s)',
      'InvalidLoopParameterParticle'          => 'Invalid loop parameter particle (%s)',
      'InvalidPropertyOwner'                  => 'Invalid property owner (%s)',
      'InvalidFunctionDefParameter'           => 'Invalid function definition parameter (%s)',
      'InvalidPropertyComparison'             => "Invalid property comparison (near: '%s %s')",
      'InvalidStringAttribute'                => 'Invalid string attribute (%s)',
      'VariableNameReserved'                  => 'Cannot declare variable with reserved name (%s)',
      'VariableNameAlreadyDelcaredAsFunction' => 'Cannot declare variable with name already declared as function (%s)',
      'VariableDoesNotExist'                  => 'Variable does not exist (%s)',
      'AttributeDoesNotExist'                 => 'Attribute does not exist (%s)',
      'ExperimentalFeature'                   => 'This feature is not yet supported (%s)',
      'AccessOfSelfAsAttribute'               => 'Cannot access attribute with same name as property owner (%s).',
      'MultipleAssignment'                    => 'Assignment found within assignment (%s)',
    }.freeze

    CUSTOM_ERRORS.each do |error, message|
      const_set error, Class.new(LexerError) do
        define_method 'initialize' do |args|
          super printf(message, *args)
        end
      end
    end
  end
end
