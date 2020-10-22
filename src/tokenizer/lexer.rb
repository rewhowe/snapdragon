require_relative '../colour_string.rb'
require_relative '../token.rb'
require_relative '../util/logger.rb'
require_relative '../util/reserved_words.rb'

require_relative 'built_ins.rb'
require_relative 'conjugator.rb'
require_relative 'context.rb'
require_relative 'errors.rb'
require_relative 'reader.rb'
require_relative 'scope.rb'
require_relative 'token_sequence.rb'

require_relative 'lexer/validators.rb'
Dir["#{__dir__}/lexer/token_processors/*.rb"].each { |f| require_relative f }

module Tokenizer
  class Lexer
    include Util

    include Validators
    include TokenProcessors

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
        Logger.debug 'READ: '.green + "\"#{chunk}\""

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

        Logger.debug 'MATCH: '.yellow + valid_token.to_s
        token = send "process_#{valid_token}", chunk
        break
      end

      validate_token_sequence chunk if token.nil?

      @last_token_type = token.type
    end

    # Value Methods
    ############################################################################
    # Methods for determining if something is considered a "value".
    ############################################################################

    # rubocop:disable Metrics/CyclomaticComplexity
    def value_type(value)
      return Token::VAL_NUM if value_number? value
      return Token::VAL_STR if value_string? value

      case value
      when /^それ$/              then Token::VAR_SORE # special
      when /^あれ$/              then Token::VAR_ARE  # special
      when /^配列$/              then Token::VAL_ARRAY # TODO: (v1.1.0) add 連想配列
      when /^(真|肯定|はい|正)$/ then Token::VAL_TRUE
      when /^(偽|否定|いいえ)$/  then Token::VAL_FALSE
      when /^(無(い|し)?|ヌル)$/ then Token::VAL_NULL
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def variable_type(value, options = { validate?: true })
      value_type(value) || begin
        raise Errors::VariableDoesNotExist, value if options[:validate?] && !variable?(value)
        Token::VARIABLE
      end
    end

    # Returns true if value is a primitive or a reserved keyword variable.
    def value?(value)
      !value_type(value).nil?
    end

    def value_number?(value)
      value =~ /^(-|ー)?([0-9０-９]+(\.|．)[0-9０-９]+|[0-9０-９]+)$/
    end

    def value_string?(value)
      value =~ /^「(\\」|[^」])*」$/
    end

    def variable?(variable)
      variable =~ /^(それ|あれ)$/ || @current_scope.variable?(variable)
    end

    # Attribute Methods
    ############################################################################
    # Methods for determining if something is considered an "attribute".
    ############################################################################

    def attribute_type(attribute, options = { validate?: true })
      return Token::ATTR_LEN  if attribute_length? attribute
      return Token::KEY_INDEX if key_index? attribute
      return Token::KEY_NAME  if value_string? attribute

      raise Errors::AttributeDoesNotExist, attribute if options[:validate?] && !variable?(attribute)
      Token::KEY_VAR
    end

    def attribute_length?(attribute)
      attribute =~ /^((長|なが)さ|(大|おお)きさ|数|かず)$/
    end

    def key_index?(attribute)
      index_match = attribute.match(/^(.+?)[#{COUNTER}]目$/)
      return unless index_match
      value? index_match[1] # TODO: (v1.1.0) should actually check value_number? instead
    end

    # Matchers
    ############################################################################

    def whitespace?(chunk)
      chunk =~ /^[#{WHITESPACE}]+$/
    end

    # Technically should include bang? as well, but not necessary for now.
    def punctuation?(chunk)
      comma?(chunk) || question?(chunk)
    end

    # Processors
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

    def sanitize_variable(value)
      # Strips leading and trailing whitespace and newlines within the string.
      # Whitespace at the beginning and ending of the string are not stripped.
      if value_string? value
        value.gsub(/[#{WHITESPACE}]*\n[#{WHITESPACE}]*/, '')
      elsif value_number? value
        value.tr 'ー．０-９', '-.0-9'
      else
        value
      end
    end

    def unindent_to(indent_level)
      until @current_scope.level == indent_level do
        try_function_close if @current_scope.type == Scope::TYPE_FUNCTION_DEF

        @tokens << Token.new(Token::SCOPE_CLOSE)

        is_alternate_branch = else_if?(@reader.peek_next_chunk) || else?(@reader.peek_next_chunk)
        @context.inside_if_block = false if @context.inside_if_block? && !is_alternate_branch

        @current_scope = @current_scope.parent
      end
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

    def begin_scope(type)
      @current_scope = Scope.new @current_scope, type
      @tokens << Token.new(Token::SCOPE_BEGIN)
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

    def loop_parameter_from_stack(particle)
      index = @stack.index { |t| t.particle == particle }

      return [nil, nil] unless index

      parameter_token = @stack.slice! index
      property_token = property_token_from_stack index

      [parameter_token, property_token]
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
