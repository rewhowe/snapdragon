require_relative '../colour_string.rb'
require_relative '../util/logger.rb'
require_relative '../util/reserved_words.rb'

require_relative 'built_ins.rb'
require_relative 'conjugator.rb'
require_relative 'context.rb'
require_relative 'errors.rb'
require_relative 'reader.rb'
require_relative 'scope.rb'
require_relative 'token.rb'
require_relative 'token_sequence.rb'
require_relative 'lexer/validators.rb'

module Tokenizer
  class Lexer
    include Util

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
    # rubocop:enable

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
    # Short (~1 line) methods for identifying tokens.
    # These perform no validation and should simply determine if a chunk matches
    # an expected token given the chunk's contents, the surrounding tokens, and
    # successive chunks.
    ############################################################################

    def whitespace?(chunk)
      chunk =~ /^[#{WHITESPACE}]+$/
    end

    def eol?(chunk)
      chunk == "\n"
    end

    def question?(chunk)
      chunk =~ /^[#{QUESTION}]$/
    end

    def bang?(chunk)
      chunk =~ /^[#{BANG}]$/
    end

    def comma?(chunk)
      chunk =~ /^[#{COMMA}]$/
    end

    # Technically should include bang? as well, but not necessary for now.
    def punctuation?(chunk)
      comma?(chunk) || question?(chunk)
    end

    # An rvalue is either a primitive, special identifier, or scoped variable.
    def rvalue?(chunk)
      value?(chunk) || @current_scope.variable?(chunk)
    end

    def assignment?(chunk)
      chunk =~ /.+は$/ && !else_if?(chunk)
    end

    def parameter?(chunk)
      chunk =~ /.+#{PARTICLE}$/ && !begin
        next_chunk = @reader.peek_next_chunk
        punctuation?(next_chunk) || comp_3_eq?(next_chunk) || comp_3_neq?(next_chunk)
      end
    end

    def function_def?(chunk)
      next_chunk = @reader.peek_next_chunk
      chunk =~ /.+とは$/ && (eol?(next_chunk) || bang?(next_chunk))
    end

    def function_call?(chunk)
      @current_scope.function?(chunk, signature_from_stack) && (
        @last_token_type == Token::EOL                               ||
        (@last_token_type == Token::PARAMETER && !parameter?(chunk)) ||
        ((@last_token_type == Token::IF || @last_token_type == Token::ELSE_IF) && question?(@reader.peek_next_chunk))
      )
    end

    def return?(chunk)
      chunk =~ /^((返|かえ)(す|る)|(戻|もど)る|なる)$/
    end

    def if?(chunk)
      chunk == 'もし'
    end

    def else_if?(chunk)
      chunk =~ /^(もしくは|または)$/
    end

    def else?(chunk)
      chunk =~ /^(それ以外|(違|ちが)えば)$/
    end

    # TODO: (v1.1.0) Remove inside_if_condition? check.
    def comp_1?(chunk)
      chunk =~ /.+が$/ && @context.inside_if_condition? && begin
        next_chunk = @reader.peek_next_chunk
        !eol?(next_chunk) && !punctuation?(next_chunk)
      end
    end

    def comp_2?(chunk)
      !chunk.empty? && question?(@reader.peek_next_chunk)
    end

    def comp_2_to?(chunk)
      chunk =~ /.+と$/ && begin
        next_chunk = @reader.peek_next_chunk
        comp_3_eq?(next_chunk) || comp_3_neq?(next_chunk)
      end
    end

    def comp_2_yori?(chunk)
      chunk =~ /.+より$/
    end

    def comp_2_gteq?(chunk)
      chunk =~ /.+以上$/
    end

    def comp_2_lteq?(chunk)
      chunk =~ /.+以下$/
    end

    def comp_3?(chunk)
      chunk == 'ならば'
    end

    def comp_3_not?(chunk)
      chunk == 'でなければ'
    end

    def comp_3_eq?(chunk)
      chunk =~ /^(等|ひと)しければ$/
    end

    def comp_3_neq?(chunk)
      chunk =~ /^(等|ひと)しくなければ$/
    end

    # rubocop:disable Layout/MultilineOperationIndentation
    # rubocop:disable Layout/SpaceAroundOperators
    def comp_3_gt?(chunk)
      chunk =~ /^(大|おお)きければ$/ ||
      chunk =~ /^(長|なが)ければ$/   ||
      chunk =~ /^(高|たか)ければ$/   ||
      chunk =~ /^(多|おお)ければ$/   ||
      false
    end

    def comp_3_lt?(chunk)
      chunk =~ /^(小|ちい)さければ$/ ||
      chunk =~ /^(短|みじか)ければ$/ ||
      chunk =~ /^(低|ひく)ければ$/   ||
      chunk =~ /^(少|すく)なければ$/ ||
      false
    end
    # rubocop:enable all

    def loop_iterator?(chunk)
      chunk =~ /^(対|たい)して$/
    end

    def loop?(chunk)
      chunk =~ /^((繰|く)り(返|かえ)す)$/
    end

    def next?(chunk)
      chunk =~ /^(次|つぎ)$/
    end

    def break?(chunk)
      chunk =~ /^(終|お)わり$/
    end

    # If followed by punctuation, this might be a variable name.
    def property?(chunk)
      chunk =~ /^.+の$/ && !punctuation?(@reader.peek_next_chunk)
    end

    def attribute?(chunk)
      is_valid_attribute = @last_token_type == Token::PROPERTY && attribute_type(chunk, validate?: false)
      is_valid_attribute && !@context.inside_if_condition? && begin
        next_chunk = @reader.peek_next_chunk
        eol?(next_chunk) || punctuation?(next_chunk)
      end
    end

    def no_op?(chunk)
      chunk == '・・・'
    end

    # Processors
    ############################################################################
    # These methods take chunks and parse their contents into particular tokens,
    # or sets of tokens, depending on the current context. Certain tokens are
    # only valid in certain situations, while others cannot be fully identified
    # until subsequent tokens have been processed.
    ############################################################################

    # On eol, check the indent for the next line.
    # Because whitespace is not tokenized, it is difficult to determine the
    # indent level when encountering a non-whitespace chunk. If we check on eol,
    # we can peek at the amount of whitespace present before it is stripped.
    def process_eol(_chunk)
      raise Errors::UnexpectedEol if @context.inside_if_condition?
      process_indent
      Token.new Token::EOL
    end

    def process_indent
      next_chunk = @reader.peek_next_chunk skip_whitespace?: false
      return if (whitespace?(next_chunk) && eol?(@reader.peek_next_chunk)) || # next line is pure whitespace
                eol?(next_chunk)                                              # next line is empty

      indent_level = next_chunk.length - next_chunk.gsub(/\A[#{WHITESPACE}]+/, '').length

      raise Errors::UnexpectedIndent if indent_level > @current_scope.level

      unindent_to indent_level if indent_level < @current_scope.level
    end

    # TODO: (v1.1.0)
    # Unless stack is empty? and peek next token is not comp_3*
    #   validate_logical_operation
    #   format logic operation (just slip comarison token in before comparators)
    def process_question(_chunk)
      token = Token.new Token::QUESTION
      if @context.inside_assignment?
        @stack << token
        try_assignment_close
      elsif @context.inside_if_condition?
        @stack << token
      else # Must be function call
        raise Errors::UnexpectedQuestion, @stack.last.content unless @stack.empty?
        @tokens << token
      end
      token
    end

    def process_bang(_chunk)
      (@tokens << Token.new(Token::BANG)).last
    end

    def process_comma(_chunk)
      raise Errors::UnexpectedComma unless @context.inside_assignment?

      unless @context.inside_array?
        @stack.insert @stack.index { |t| t.type == Token::ASSIGNMENT } + 1, Token.new(Token::ARRAY_BEGIN)
        @context.inside_array = true
      end

      if eol? @reader.peek_next_chunk
        # eat until peeked EOL token, then discard it
        loop while whitespace? @reader.next_chunk
      end
      raise Errors::UnexpectedEof if @reader.peek_next_chunk.empty?

      (@stack << Token.new(Token::COMMA)).last
    end

    # TODO: (v1.1.0) Cannot assign keys / indices to themselves. (Fix at same time as process_attribute)
    # No need to validate variable_type because the matcher checks either
    # primitive or existing variable.
    def process_rvalue(chunk)
      chunk = sanitize_variable chunk
      token = Token.new Token::RVALUE, chunk, sub_type: variable_type(chunk)

      @stack << token

      try_assignment_close

      token
    end

    # TODO: (v1.1.0) Set sub type for associative arrays (KEY_INDEX, KEY_NAME, KEY_VARIABLE).
    # TODO: (v1.1.0) Raise an error when assigning to a read-only property.
    # Currently only variables can be assigned to.
    def process_assignment(chunk)
      raise Errors::MultipleAssignment, chunk if @context.inside_assignment?
      @context.inside_assignment = true

      name = chunk.chomp 'は'
      validate_variable_name name
      (@stack << Token.new(Token::ASSIGNMENT, name, sub_type: variable_type(name, validate?: false))).last
    end

    def process_parameter(chunk)
      particle = chunk.match(/(#{PARTICLE})$/)[1]
      variable = sanitize_variable chunk.chomp! particle

      if !@stack.empty? && @stack.last.type == Token::PROPERTY
        property_token = @stack.last
        parameter_sub_type = attribute_type variable
      else
        parameter_sub_type = variable_type variable, validate?: false # function def parameters may not exist
      end

      parameter_token = Token.new Token::PARAMETER, variable, particle: particle, sub_type: parameter_sub_type

      # NOTE: Untested (redundant check)
      validate_property_and_attribute property_token, parameter_token if property_token

      (@stack << parameter_token).last
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
        @tokens << token
      end

      @stack.clear

      name = chunk.chomp 'とは'
      validate_function_name name, signature

      token = Token.new Token::FUNCTION_DEF, name
      @tokens << token

      should_force = bang? @reader.peek_next_chunk
      @current_scope.add_function name, signature, force?: should_force
      begin_scope Scope::TYPE_FUNCTION_DEF
      parameter_names.each { |parameter| @current_scope.add_variable parameter }

      token
    end

    def process_function_call(chunk)
      destination = @context.inside_if_condition? ? @stack : @tokens

      signature = signature_from_stack
      function = @current_scope.get_function chunk, signature

      function_call_parameters_from_stack(function).each { |t| destination << t }

      token = Token.new(
        Token::FUNCTION_CALL,
        function[:name],
        sub_type: function[:built_in?] ? Token::FUNC_BUILT_IN : Token::FUNC_USER
      )
      (destination << token).last
    end

    # Adds implicit それ for 返す and 無 for 返る/戻る.
    def process_return(chunk)
      raise Errors::UnexpectedReturn, chunk if @context.inside_if_condition?

      parameter_token = @stack.pop

      if parameter_token.nil?
        parameter_token = begin
          case chunk
          when /^(返|かえ)す$/
            Token.new Token::PARAMETER, 'それ', particle: 'を', sub_type: Token::VAR_SORE
          when /^(返|かえ|戻|もど)る$/
            Token.new Token::PARAMETER, '無', particle: 'を', sub_type: Token::VAL_NULL
          end
        end
      end

      property_token = @stack.pop
      validate_return_parameter chunk, parameter_token, property_token

      # Something else was in the stack
      raise Errors::UnexpectedReturn, chunk unless @stack.empty?

      @tokens += [property_token, parameter_token].compact
      (@tokens << Token.new(Token::RETURN)).last
    end

    def process_if(_chunk)
      @context.inside_if_condition = true
      (@tokens << Token.new(Token::IF)).last
    end

    def process_else_if(_chunk)
      raise Errors::UnexpectedElseIf unless @context.inside_if_block?
      @context.inside_if_condition = true
      (@tokens << Token.new(Token::ELSE_IF)).last
    end

    def process_else(_chunk)
      raise Errors::UnexpectedElse unless @context.inside_if_block?
      token = Token.new Token::ELSE
      @tokens << token
      @context.inside_if_condition = true
      close_if_statement
      token
    end

    def process_comp_1(chunk)
      @stack << comp_token(chunk.chomp('が'))
      Token.new Token::COMP_1
    end

    def process_comp_2(chunk)
      @stack << comp_token(chunk)
      Token.new Token::COMP_2
    end

    def process_comp_2_to(chunk)
      @stack << comp_token(chunk.chomp('と'))
      Token.new Token::COMP_2_TO
    end

    def process_comp_2_yori(chunk)
      @stack << comp_token(chunk.chomp('より'))
      Token.new Token::COMP_2_YORI
    end

    def process_comp_2_gteq(chunk)
      @stack << comp_token(chunk.chomp('以上'))
      Token.new Token::COMP_2_GTEQ
    end

    def process_comp_2_lteq(chunk)
      @stack << comp_token(chunk.chomp('以下'))
      Token.new Token::COMP_2_LTEQ
    end

    def process_comp_3(chunk, options = { reverse?: false })
      case @last_token_type
      when Token::QUESTION
        @stack.pop # drop question
        comparison_tokens = [Token.new(Token::COMP_EQ)]
        comparison_tokens << Token.new(Token::RVALUE, '真', sub_type: Token::VAL_TRUE) if stack_is_truthy_check?
      when Token::COMP_2_LTEQ
        comparison_tokens = [Token.new(Token::COMP_LTEQ)]
      when Token::COMP_2_GTEQ
        comparison_tokens = [Token.new(Token::COMP_GTEQ)]
      else
        raise Errors::UnexpectedInput, chunk
      end

      flip_comparison comparison_tokens if options[:reverse?]
      close_if_statement comparison_tokens
    end

    def process_comp_3_not(chunk)
      process_comp_3 chunk, reverse?: true
    end

    def process_comp_3_eq(_chunk)
      close_if_statement [Token.new(Token::COMP_EQ)]
    end

    def process_comp_3_neq(_chunk)
      close_if_statement [Token.new(Token::COMP_NEQ)]
    end

    def process_comp_3_gt(_chunk)
      close_if_statement [Token.new(Token::COMP_GT)]
    end

    def process_comp_3_lt(_chunk)
      close_if_statement [Token.new(Token::COMP_LT)]
    end

    # If stack size is 1: the loop iterator parameter is a variable or string.
    # If stack size is 2: the loop iterator parameter is a property and key attribute. (v1.1.0)
    def process_loop_iterator(_chunk)
      raise Errors::UnexpectedLoop if ![1, 2].include?(@stack.size) || @context.inside_if_condition?

      parameter_token = @stack.pop
      property_token = @stack.pop
      validate_loop_iterator_parameter parameter_token, property_token

      @tokens << parameter_token
      (@tokens << Token.new(Token::LOOP_ITERATOR)).last
    end

    # If stack size is 2: the loop parameters are the start and end values.
    # If stack size is 3: one parameter is a value and the other is a property.
    # If stack size is 4: the loop parameters are the start and end values, as properties.
    def process_loop(_chunk)
      if [2, 3, 4].include? @stack.size
        (start_parameter, start_property) = loop_parameter_from_stack 'から'
        (end_parameter, end_property)     = loop_parameter_from_stack 'まで'

        unless @stack.empty?
          invalid_particle_token = @stack.find { |t| t.particle && !%w[から まで].include?(t.particle) }
          raise Errors::InvalidLoopParameterParticle, invalid_particle_token.particle if invalid_particle_token
          raise Errors::UnexpectedLoop
        end

        validate_loop_parameters start_parameter, start_property
        validate_loop_parameters end_parameter, end_property

        @tokens += [start_property, start_parameter, end_property, end_parameter].compact
      elsif !@stack.empty?
        raise Errors::UnexpectedLoop
      end

      token = Token.new Token::LOOP
      @tokens << token
      begin_scope Scope::TYPE_LOOP
      token
    end

    def process_next(_chunk)
      validate_scope Scope::TYPE_LOOP, ignore: [Scope::TYPE_IF_BLOCK]
      (@tokens << Token.new(Token::NEXT)).last
    end

    def process_break(_chunk)
      validate_scope Scope::TYPE_LOOP, ignore: [Scope::TYPE_IF_BLOCK]
      (@tokens << Token.new(Token::BREAK)).last
    end

    def process_property(chunk)
      chunk.chomp! 'の'
      sub_type = variable_type chunk
      # TODO: (v1.1.0) Allow Token::VAL_NUM for Exp, Log, and Root.
      valid_property_owners = [Token::VARIABLE, Token::VAR_SORE, Token::VAR_ARE, Token::VAL_STR]
      raise Errors::InvalidPropertyOwner, chunk unless valid_property_owners.include? sub_type
      (@stack << Token.new(Token::PROPERTY, chunk, sub_type: sub_type)).last
    end

    # TODO: (v1.1.0) Cannot assign keys / indices to themselves. (Fix at same time as process_rvalue)
    def process_attribute(chunk)
      chunk = sanitize_variable chunk
      attribute_sub_type = attribute_type chunk

      attribute_token = Token.new Token::ATTRIBUTE, chunk, sub_type: attribute_sub_type

      property_token = @stack.last
      validate_property_and_attribute property_token, attribute_token

      @stack << attribute_token

      try_assignment_close

      attribute_token
    end

    def process_no_op(_chunk)
      (@tokens << Token.new(Token::NO_OP)).last
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
