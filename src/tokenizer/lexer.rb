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

module Tokenizer
  class Lexer
    include Util

    # rubocop:disable Layout/ExtraSpacing
    PARTICLE       = '(から|と|に|へ|まで|で|を)'.freeze # 使用可能助詞
    COUNTER        = %w[つ 人 個 匹 子 頭].freeze        # 使用可能助数詞
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

      unindent_to 0 if @reader.finished?

      @tokens.shift
    rescue Errors::LexerError => e
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
      return Token::VAR_NUM if value_number? value
      return Token::VAR_STR if value_string? value

      case value
      when /^それ$/              then Token::VAR_SORE # special
      when /^あれ$/              then Token::VAR_ARE  # special
      when /^配列$/              then Token::VAR_ARRAY # TODO: (v1.1.0) add 連想配列
      when /^(真|肯定|はい|正)$/ then Token::VAR_BOOL
      when /^(偽|否定|いいえ)$/  then Token::VAR_BOOL
      when /^(無(い|し)?|ヌル)$/ then Token::VAR_NULL
      end
    end
    # rubocop:enable

    def variable_type(value, options = { validate?: false })
      value_type(value) || begin
        raise Errors::UnexpectedInput if options[:validate?] && !@current_scope.variable?(value)
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

    # Specifically, anything that can be treated as an rvalue.
    def variable?(chunk)
      value?(chunk) || @current_scope.variable?(chunk)
    end

    def assignment?(chunk)
      chunk =~ /.+は$/ && !else_if?(chunk)
    end

    def parameter?(chunk)
      chunk =~ /.+#{PARTICLE}$/ && !eol?(@reader.peek_next_chunk)
    end

    def function_def?(chunk)
      next_chunk = @reader.peek_next_chunk
      chunk =~ /.+とは$/ && (eol?(next_chunk) || bang?(next_chunk))
    end

    def function_call?(chunk)
      @current_scope.function?(chunk, signature_from_stack(should_consume?: false)) && (
        @last_token_type == Token::EOL                               ||
        (@last_token_type == Token::PARAMETER && !parameter?(chunk)) ||
        (@last_token_type == Token::IF && question?(@reader.peek_next_chunk))
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

    def comp_1?(chunk)
      chunk =~ /.+が$/ && variable?(chunk.chomp('が'))
    end

    def comp_2?(chunk)
      variable?(chunk) && question?(@reader.peek_next_chunk)
    end

    def comp_2_to?(chunk)
      chunk =~ /.+と$/ && variable?(chunk.chomp('と'))
    end

    def comp_2_yori?(chunk)
      chunk =~ /.+より$/ && variable?(chunk.chomp('より'))
    end

    def comp_2_gteq?(chunk)
      chunk =~ /.+以上$/ && variable?(chunk.chomp('以上'))
    end

    def comp_2_lteq?(chunk)
      chunk =~ /.+以下$/ && variable?(chunk.chomp('以下'))
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

    # rubocop:disable all
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

    def process_question(chunk)
      token = Token.new Token::QUESTION
      if @context.inside_if_condition?
        @stack << token
      else
        raise Errors::TrailingCharacters, chunk unless eol?(@reader.peek_next_chunk)
        @tokens << token
      end
      token
    end

    def process_bang(_chunk)
      (@tokens << Token.new(Token::BANG)).last
    end

    def process_comma(_chunk)
      unless @context.inside_array?
        @tokens << Token.new(Token::ARRAY_BEGIN)
        @tokens << @stack.pop
        @context.inside_array = true
      end

      (@tokens << Token.new(Token::COMMA)).last
    end

    # No need to validate variable_type because the matcher checks either
    # primitive or existing variable.
    def process_variable(chunk)
      chunk = sanitize_variable chunk
      token = Token.new Token::VARIABLE, chunk, sub_type: variable_type(chunk)

      if @context.inside_array?
        @tokens << token
        check_array_close
      elsif comma? @reader.peek_next_chunk
        @stack << token
      else
        @tokens << token
      end

      token
    end

    # TODO: (v1.1.0) Set sub type for associative arrays (index, key, etc.).
    # Currently only variables can be assigned to.
    def process_assignment(chunk)
      name = chunk.chomp 'は'

      validate_variable_name name

      @current_scope.add_variable name
      (@tokens << Token.new(Token::ASSIGNMENT, name, sub_type: variable_type(name))).last
    end

    def process_parameter(chunk)
      particle = chunk.match(/(#{PARTICLE})$/)[1]
      variable = sanitize_variable chunk.chomp! particle
      sub_type = variable_type variable
      (@stack << Token.new(Token::PARAMETER, variable, particle: particle, sub_type: sub_type)).last
    end

    def process_function_def(chunk)
      raise Errors::UnexpectedFunctionDef, chunk if @context.inside_if_condition?

      validate_scope(
        Scope::TYPE_MAIN,
        ignore: [Scope::TYPE_IF_BLOCK, Scope::TYPE_FUNCTION_DEF], error_class: Errors::UnexpectedFunctionDef
      )

      signature = signature_from_stack should_consume?: false
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

      stack = @stack.clone

      signature = signature_from_stack
      function = @current_scope.get_function chunk, signature

      function_call_parameters(function, stack).each { |t| destination << t }

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
            Token.new Token::PARAMETER, '無', particle: 'を', sub_type: Token::VAR_NULL
          end
        end
      end

      validate_return_parameter chunk, parameter_token

      @tokens << parameter_token
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
      close_if_statement
      token
    end

    def process_comp_1(chunk)
      chunk.chomp! 'が'
      @stack << Token.new(Token::VARIABLE, chunk, sub_type: variable_type(chunk))
      Token.new Token::COMP_1
    end

    def process_comp_2(chunk)
      @stack << Token.new(Token::VARIABLE, chunk, sub_type: variable_type(chunk))
      Token.new Token::COMP_2
    end

    def process_comp_2_to(chunk)
      chunk.chomp! 'と'
      @stack << Token.new(Token::VARIABLE, chunk, sub_type: variable_type(chunk))
      Token.new Token::COMP_2_TO
    end

    def process_comp_2_yori(chunk)
      chunk.chomp! 'より'
      @stack << Token.new(Token::VARIABLE, chunk, sub_type: variable_type(chunk))
      Token.new Token::COMP_2_YORI
    end

    def process_comp_2_gteq(chunk)
      chunk.chomp! '以上'
      @stack << Token.new(Token::VARIABLE, chunk, sub_type: variable_type(chunk))
      Token.new Token::COMP_2_GTEQ
    end

    def process_comp_2_lteq(chunk)
      chunk.chomp! '以下'
      @stack << Token.new(Token::VARIABLE, chunk, sub_type: variable_type(chunk))
      Token.new Token::COMP_2_LTEQ
    end

    def process_comp_3(chunk, options = { reverse?: false })
      case @last_token_type
      when Token::QUESTION
        @stack.pop # drop question
        comparison_tokens = [Token.new(Token::COMP_EQ)]
        comparison_tokens << Token.new(Token::VARIABLE, '真', sub_type: Token::VAR_BOOL) unless stack_is_comparison?
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

    # TODO: this logic will have to be adjusted when implementing properties
    # (stack size will be 2 with the second being parameter with sub type
    def process_loop_iterator(_chunk)
      raise Errors::UnexpectedLoop if @stack.size != 1 || @context.inside_if_condition?

      parameter_token = @stack.pop
      validate_loop_iterator_parameter parameter_token

      @tokens << parameter_token
      (@tokens << Token.new(Token::LOOP_ITERATOR)).last
    end

    # TODO: this logic will have to be adjusted when implementing properties
    # (stack size will be 2 or 4 with the 2nd/4th being parameter with sub type
    def process_loop(_chunk)
      if @stack.size == 2
        @stack.sort_by!(&:particle)
        validate_loop_parameters

        @tokens += @stack
        @stack.clear
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

    def process_no_op(_chunk)
      (@tokens << Token.new(Token::NO_OP)).last
    end

    # Validators
    ############################################################################
    # Methods for determining the validity of chunks.
    # These methods should not mutate or return any value, simply throw an error
    # if the current state is considered invalid.
    ############################################################################

    def validate_token_sequence(chunk)
      raise Errors::UnexpectedEol if eol? chunk
      raise Errors::UnexpectedInput, chunk
    end

    def validate_variable_name(name)
      raise Errors::AssignmentToValue, name if value?(name) && name !~ /^(それ|あれ)$/
      raise Errors::VariableNameReserved, name if ReservedWords.variable? name
      raise Errors::VariableNameAlreadyDelcaredAsFunction, name if @current_scope.function? name
    end

    def validate_function_def_parameter(token, parameters)
      raise Errors::UnexpectedInput if token.type != Token::PARAMETER # NOTE: Untested
      raise Errors::FunctionDefPrimitiveParameters if token.sub_type != Token::VARIABLE
      raise Errors::FunctionDefDuplicateParameters if parameters.include? token.content
    end

    def validate_function_name(name, signature)
      raise Errors::FunctionDefNonVerbName, name unless Conjugator.verb? name
      raise Errors::FunctionDefAlreadyDeclared, name if @current_scope.function? name, signature
      raise Errors::FunctionDefReserved, name if ReservedWords.function? name
    end

    def validate_function_call_parameter(token)
      return if token.sub_type != Token::VARIABLE || @current_scope.variable?(token.content)
      raise Errors::UnexpectedInput, token.content
    end

    def validate_return_parameter(chunk, token)
      raise Errors::UnexpectedReturn, chunk unless token
      raise Errors::UnexpectedInput, @stack.last unless @stack.empty?
      unless @current_scope.variable?(token.content) || value?(token.content)
        raise Errors::InvalidReturnParameter, token.content
      end

      validate_return_parameter_particle chunk, token if token
    end

    def validate_return_parameter_particle(chunk, token)
      expected_particle = chunk == 'なる' ? 'と' : 'を'
      return if token.particle == expected_particle
      raise Errors::InvalidReturnParameterParticle.new(token.particle, expected_particle)
    end

    def validate_loop_iterator_parameter(token)
      raise Errors::InvalidLoopParameterParticle, token.particle unless token.particle == 'に'
      raise Errors::UnexpectedInput, token.particle unless token.particle == 'に'
      return if @current_scope.variable?(token.content) || value_string?(token.content)
      raise Errors::InvalidLoopParameter, token.content
    end

    def validate_loop_parameters
      valid_sub_types = [Token::VARIABLE, Token::VAR_NUM]
      %w[から まで].each_with_index do |particle, i|
        raise Errors::InvalidLoopParameterParticle, @stack[i].particle unless @stack[i].particle == particle
        raise Errors::InvalidLoopParameter, @stack[i] unless valid_sub_types.include? @stack[i].sub_type
      end
    end

    def validate_scope(expected_type, options = { ignore: [], error_class: nil })
      current_scope = @current_scope
      until current_scope.nil? || current_scope.type == expected_type
        unless options[:ignore].include? current_scope.type
          # rubocop:disable Style/RaiseArgs
          raise options[:error_class].new current_scope.type unless options[:error_class].nil?
          # rubocop:enable Style/RaiseArgs
          raise Errors::UnexpectedScope.new expected_type, current_scope.type
        end
        current_scope = current_scope.parent
      end
      raise "Expected scope #{expected_type} not found" if current_scope.nil? # NOTE: Untested
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
        check_function_return if @current_scope.type == Scope::TYPE_FUNCTION_DEF

        @tokens << Token.new(Token::SCOPE_CLOSE)

        is_alternate_branch = else_if?(@reader.peek_next_chunk) || else?(@reader.peek_next_chunk)
        @context.inside_if_block = false if @context.inside_if_block? && !is_alternate_branch

        @current_scope = @current_scope.parent
      end
    end

    def check_array_close
      if eol?(@reader.peek_next_chunk)
        close_array
      elsif !comma?(@reader.peek_next_chunk)
        raise Errors::TrailingCharacters, 'array'
      end
    end

    def close_array
      @tokens << Token.new(Token::ARRAY_CLOSE)
      @context.inside_array = false
    end

    # If the last token of a function is not a return, return null.
    def check_function_return
      return if @last_token_type == Token::RETURN

      @tokens += [
        Token.new(Token::PARAMETER, '無', particle: 'を', sub_type: Token::VAR_NULL),
        Token.new(Token::RETURN)
      ]
    end

    def begin_scope(type)
      @current_scope = Scope.new @current_scope, type
      @tokens << Token.new(Token::SCOPE_BEGIN)
    end

    # TODO: Needs refactoring to get only the particles. When working with
    # properties, there needs to be a way to keep track of which parameter is a
    # property (and whose).
    def signature_from_stack(options = { should_consume?: true })
      signature = @stack.select { |t| t.type == Token::PARAMETER } .map do |token|
        { name: token.content, particle: token.particle }
      end
      @stack.clear if options[:should_consume?]
      signature
    end

    def function_call_parameters(function, stack)
      parameter_tokens = []

      function[:signature].each do |signature_parameter|
        index = stack.index { |t| t.type == Token::PARAMETER && t.particle == signature_parameter[:particle] }
        parameter_token = stack.slice! index
        # TODO: get property owner token from index - 1

        validate_function_call_parameter parameter_token

        parameter_tokens << parameter_token
      end

      if parameter_tokens.size == 1 && function[:built_in?] && BuiltIns.math?(function[:name])
        parameter_tokens.unshift Token.new Token::PARAMETER, 'それ', sub_type: Token::VAR_SORE
      end

      parameter_tokens
    end

    # TODO: Needs refactoring to consider properties.
    def stack_is_comparison?
      @stack.size == 2 && @stack.all? { |token| token.type == Token::VARIABLE }
    end

    def close_if_statement(comparison_tokens = [])
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
