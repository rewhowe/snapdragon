require_relative '../colour_string'
require_relative '../token'
require_relative '../oracles/attribute'
require_relative '../oracles/value'
require_relative '../util/logger'
require_relative '../util/reserved_words'

require_relative 'built_ins'
require_relative 'conjugator'
require_relative 'context'
require_relative 'errors'
require_relative 'reader'
require_relative 'scope'
require_relative 'token_sequence'

require_relative 'lexer/validators'
Dir["#{__dir__}/lexer/token_lexers/*.rb"].each { |f| require_relative f }

module Tokenizer
  class Lexer
    ############################################################################
    # TokenLexers consist of ONLY matching and processing methods.
    #
    # Matching:
    # Short (~1 line) methods for identifying tokens.
    # These perform no validation and should simply determine if a chunk matches
    # an expected token given the chunk's contents, the surrounding tokens, and
    # successive chunks.
    #
    # Processing:
    # These methods take chunks and parse their contents into particular tokens,
    # or sets of tokens, depending on the current context. Certain tokens are
    # only valid in certain situations, while others cannot be fully identified
    # until subsequent tokens have been processed.
    #
    # Any other common or helper methods will be in this file.
    ############################################################################
    include TokenLexers

    ############################################################################
    # Methods for determining the validity of chunks.
    # These methods should not mutate or return any value, simply throw an error
    # if the current state is considered invalid.
    ############################################################################
    include Validators

    # rubocop:disable Layout/ExtraSpacing
    PARTICLE       = '(から|と|に|へ|まで|で|を)'.freeze # 使用可能助詞
    COUNTER        = 'つ人個件匹'.freeze                 # 使用可能助数詞
    WHITESPACE     = " \t　".freeze                      # 空白文字
    COMMA          = ',、'.freeze
    QUESTION       = '?？'.freeze
    BANG           = '!！'.freeze
    INLINE_COMMENT = '(（'.freeze
    # rubocop:enable Layout/ExtraSpacing

    def initialize(reader = Reader.new, options = {})
      @reader  = reader
      @options = options

      @context       = Context.new
      @current_scope = Scope.new
      BuiltIns.inject_into @current_scope

      # The finalised token output. At any time, it may contain as many or as few tokens as required to complete a
      # sequence (as some tokens cannot be uniquely identified until subsequent tokens are parsed).
      @tokens = []
      # The last token parsed in the sequence. It may not be present in @tokens, but is guaranteed to represent the last
      # token parsed.
      @last_token_type = Token::EOL
      # The current stack of tokens which are part of a sequence that must be qualified in its entirety. For example,
      # the conditions of an if-statement or the parameters in a function definition, function call, or other structure.
      @stack = []
    end

    # If there are tokens in the buffer, return one immediately.
    # Otherwise, loop getting tokens until we have at least 1, or until the
    # Reader is finished.
    def next_token
      while !@reader.finished? && @tokens.empty? do
        chunk = @reader.next_chunk
        Util::Logger.debug 'READ: '.green + "\"#{chunk}\""

        break if chunk.nil?

        tokenize chunk
      end

      if @reader.finished?
        unindent_to 0
        validate_sequence_finish
      end

      @tokens.shift
    rescue Errors::BaseError => e
      e.line_num = @reader.line_num
      raise
    end

    private

    def tokenize(chunk)
      return if whitespace? chunk

      token = nil

      TOKEN_SEQUENCE[@last_token_type].each do |valid_token|
        next unless send "#{valid_token}?", chunk

        Util::Logger.debug 'MATCH: '.yellow + valid_token.to_s
        token = send "process_#{valid_token}", chunk
        break
      end

      validate_token_sequence chunk if token.nil?

      @last_token_type = token.type
    end

    # Variable Methods
    ############################################################################

    def variable_type(value, options = { validate?: true })
      Oracles::Value.type(value) || begin
        raise Errors::VariableDoesNotExist, value if options[:validate?] && !variable?(value)
        Token::VARIABLE
      end
    end

    def variable?(variable)
      variable =~ /^(それ|あれ)$/ || @current_scope.variable?(variable)
    end

    def sanitize_variable(value)
      # Strips leading and trailing whitespace and newlines within the string.
      # Whitespace at the beginning and ending of the string are not stripped.
      if Oracles::Value.string? value
        value.gsub(/[#{WHITESPACE}]*\n[#{WHITESPACE}]*/, '')
      elsif Oracles::Value.number? value
        value.tr 'ー．０-９', '-.0-9'
      else
        value
      end
    end

    # Attribute Methods
    ############################################################################

    def attribute_type(attribute, options = { validate?: true })
      type = Oracles::Attribute.type attribute
      if options[:validate?] && type == Token::KEY_VAR && !variable?(attribute)
        raise Errors::AttributeDoesNotExist, attribute
      end
      type
    end

    # Common Matchers
    ############################################################################

    def whitespace?(chunk)
      chunk =~ /^[#{WHITESPACE}]+$/
    end

    # Technically should include bang? as well, but not necessary for now.
    def punctuation?(chunk)
      comma?(chunk) || question?(chunk)
    end

    # Common Processors
    ############################################################################

    def process_indent
      next_chunk = @reader.peek_next_chunk skip_whitespace?: false
      return if (whitespace?(next_chunk) && eol?(@reader.peek_next_chunk)) || # next line is pure whitespace
                eol?(next_chunk)                                              # next line is empty

      indent_level = next_chunk.length - next_chunk.gsub(/\A[#{WHITESPACE}]+/, '').length

      raise Errors::UnexpectedIndent if indent_level > @current_scope.level

      unindent_to indent_level if indent_level < @current_scope.level
    end

    # Helpers
    ############################################################################

    def unindent_to(indent_level)
      until @current_scope.level == indent_level do
        try_function_close if @current_scope.type == Scope::TYPE_FUNCTION_DEF

        @tokens << Token.new(Token::SCOPE_CLOSE)

        is_alternate_branch = else_if?(@reader.peek_next_chunk) || else?(@reader.peek_next_chunk)
        @context.inside_if_block = false if @context.inside_if_block? && !is_alternate_branch

        @current_scope = @current_scope.parent
      end
    end

    def begin_scope(type)
      @current_scope = Scope.new @current_scope, type
      @tokens << Token.new(Token::SCOPE_BEGIN)
    end

    # If the last token of a function is not a return, return null.
    def try_function_close
      return if @last_token_type == Token::RETURN

      @tokens += [
        Token.new(Token::PARAMETER, '無', particle: 'を', sub_type: Token::VAL_NULL),
        Token.new(Token::RETURN)
      ]
    end

    def try_assignment_close
      return false unless eol? @reader.peek_next_chunk

      if @context.inside_array?
        @stack << Token.new(Token::ARRAY_CLOSE)
        @context.inside_array = false
      end

      close_assignment
    end

    def close_assignment
      assignment_token = @stack.shift

      # TODO: (v1.1.0) or 1st token is PROPERTY and 2nd is ASSIGNMENT
      unless assignment_token.type == Token::ASSIGNMENT
        raise Errors::UnexpectedInput, assignment_token.content || assignment_token.to_s.upcase
      end

      @context.inside_assignment = false
      @current_scope.add_variable assignment_token.content

      @tokens << assignment_token
      @tokens += @stack
      @stack.clear
    end

    def close_if_statement(comparison_tokens = [])
      raise Errors::UnexpectedComparison unless @context.inside_if_condition?

      validate_logical_operation

      @tokens += comparison_tokens unless comparison_tokens.empty?
      @tokens += @stack
      @stack.clear

      @context.inside_if_condition = false
      @context.inside_if_block = true

      begin_scope Scope::TYPE_IF_BLOCK

      Token.new Token::COMP_3
    end

    # Unlike the other *_from_stack methods, this is non-destructive.
    # Builds a parameter signature from the stack. For function retrieval, only
    # the particles are required, however the names are required for function
    # definitions.
    def signature_from_stack
      @stack.select { |t| t.type == Token::PARAMETER } .map do |token|
        { name: token.content, particle: token.particle }
      end
    end

    def function_call_parameters_from_stack(function)
      parameter_tokens = []

      function[:signature].each do |signature_parameter|
        index = @stack.index { |t| t.type == Token::PARAMETER && t.particle == signature_parameter[:particle] }
        parameter_token = @stack.slice! index

        property_token = property_token_from_stack index
        validate_parameter parameter_token, property_token

        parameter_tokens += [property_token, parameter_token].compact
      end

      # Something else was in the stack
      raise Errors::UnexpectedFunctionCall, function[:name] unless @stack.empty?

      num_parameters = parameter_tokens.count(&:particle)
      if num_parameters == 1 && function[:built_in?] && BuiltIns.math?(function[:name])
        parameter_tokens.unshift Token.new Token::PARAMETER, 'それ', sub_type: Token::VAR_SORE
      end

      parameter_tokens
    end

    def loop_parameter_from_stack(particle)
      index = @stack.index { |t| t.particle == particle }

      return [nil, nil] unless index

      parameter_token = @stack.slice! index
      property_token = property_token_from_stack index

      [parameter_token, property_token]
    end

    def property_token_from_stack(index)
      @stack.slice!(index - 1) if index.positive? && @stack[index - 1].type == Token::PROPERTY
    end

    def comp_token(chunk)
      chunk = sanitize_variable chunk

      if @last_token_type == Token::PROPERTY
        property_token = @stack.last
        parameter_token = Token.new Token::ATTRIBUTE, chunk, sub_type: attribute_type(chunk)
        validate_property_and_attribute property_token, parameter_token
      else
        raise Errors::VariableDoesNotExist, chunk unless rvalue? chunk
        parameter_token = Token.new Token::RVALUE, chunk, sub_type: variable_type(chunk)
      end

      parameter_token
    end

    def stack_is_truthy_check?
      (@stack.size == 1 && @stack.first.type == Token::RVALUE) ||
        (@stack.size == 2 && @stack.first.type == Token::PROPERTY) ||
        (@stack.size >= 1 && @stack.last.type == Token::FUNCTION_CALL)
    end

    # Currently only flips COMP_EQ, COMP_LTEQ, COMP_GTEQ
    def flip_comparison(comparison_tokens)
      case comparison_tokens.first.type
      when Token::COMP_EQ   then comparison_tokens.first.type = Token::COMP_NEQ
      when Token::COMP_LTEQ then comparison_tokens.first.type = Token::COMP_GT
      when Token::COMP_GTEQ then comparison_tokens.first.type = Token::COMP_LT
      end
    end
  end
end
