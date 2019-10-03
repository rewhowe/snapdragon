require_relative '../colour_string.rb'
require_relative '../util/logger.rb'

require_relative 'built_ins.rb'
require_relative 'conjugator.rb'
require_relative 'context.rb'
require_relative 'errors.rb'
require_relative 'reader.rb'
require_relative 'scope.rb'
require_relative 'token.rb'

module Tokenizer
  class Lexer
    include Util

    # rubocop:disable Layout/ExtraSpacing
    PARTICLE       = '(から|と|に|へ|まで|で|を)'.freeze # 使用可能助詞
    COUNTER        = %w[つ 人 個 匹 子 頭].freeze        # 使用可能助数詞
    WHITESPACE     = " \t　".freeze                      # 空白文字
    COMMA          = ',、'.freeze
    QUESTION       = '?？'.freeze
    BANG           = '[!！]'.freeze
    INLINE_COMMENT = '(（'.freeze
    # rubocop:enable Layout/ExtraSpacing

    TOKEN_SEQUENCE = {
      Token::EOL => [
        Token::EOL,
        Token::FUNCTION_CALL,
        Token::FUNCTION_DEF,
        Token::NO_OP,
        Token::ASSIGNMENT,
        Token::PARAMETER,
        Token::IF,
        Token::ELSE_IF,
        Token::ELSE,
        Token::LOOP,
        Token::NEXT,
        Token::BREAK,
      ],
      Token::ASSIGNMENT => [
        Token::VARIABLE,
      ],
      Token::VARIABLE => [
        Token::EOL,
        Token::QUESTION,
        Token::COMMA,
      ],
      Token::PARAMETER => [
        Token::PARAMETER,
        Token::FUNCTION_DEF,
        Token::FUNCTION_CALL,
        Token::LOOP,
        Token::LOOP_ITERATOR,
      ],
      Token::FUNCTION_DEF => [
        Token::EOL,
      ],
      Token::FUNCTION_CALL => [
        Token::EOL,
        Token::QUESTION,
        Token::BANG,
      ],
      Token::NO_OP => [
        Token::EOL,
      ],
      Token::QUESTION => [
        Token::EOL,
        Token::COMP_3,
        Token::COMP_3_NOT, # next: COMP_3
      ],
      Token::BANG => [
        Token::EOL,
        Token::QUESTION,
      ],
      Token::COMMA => [
        Token::VARIABLE,
      ],
      Token::IF => [
        Token::PARAMETER,
        Token::FUNCTION_CALL,
        Token::COMP_1,
        Token::COMP_2,
      ],
      Token::ELSE_IF => [
        Token::PARAMETER,
        Token::COMP_1,
        Token::COMP_2,
      ],
      Token::ELSE => [
        Token::EOL,
      ],
      Token::COMP_1 => [
        Token::COMP_2,
        Token::COMP_2_TO,
        Token::COMP_2_YORI,
        Token::COMP_2_GTEQ,
        Token::COMP_2_LTEQ,
      ],
      Token::COMP_2 => [
        Token::QUESTION,
      ],
      Token::COMP_2_TO => [
        Token::COMP_3_EQ,  # next: COMP_3
        Token::COMP_3_NEQ, # next: COMP_3
      ],
      Token::COMP_2_YORI => [
        Token::COMP_3_LT, # next: COMP_3
        Token::COMP_3_GT, # next: COMP_3
      ],
      Token::COMP_2_GTEQ => [
        Token::COMP_3,
      ],
      Token::COMP_2_LTEQ => [
        Token::COMP_3,
      ],
      Token::COMP_3 => [
        Token::EOL,
      ],
      Token::LOOP_ITERATOR => [
        Token::LOOP,
      ],
      Token::LOOP => [
        Token::EOL,
      ],
      Token::NEXT => [
        Token::EOL,
      ],
      Token::BREAK => [
        Token::EOL,
      ],
    }.freeze

    def initialize(reader = Reader.new, options = {})
      @reader  = reader
      @options = options

      @context       = Context.new
      @current_scope = Scope.new
      BuiltIns.inject_into @current_scope

      @tokens = []
      @last_token_type = Token::EOL
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

      raise_token_sequence_error chunk if token.nil?

      @last_token_type = token.type
    end

    def raise_token_sequence_error(chunk)
      raise Errors::UnexpectedEol if eol? chunk
      raise Errors::UnexpectedInput, chunk
    end

    # Matchers
    ############################################################################
    # Short (~1 line) methods for identifying tokens.
    # These perform no validation and should simply determine if a chunk matches
    # an expected token given the chunk's contents, the surrounding tokens, and
    # successive chunks.
    ############################################################################

    # rubocop:disable all
    def value?(value)
      value =~ /^(それ|あれ)$/       || # special
      value_number?(value)           ||
      value_string?(value)           ||
      value =~ /^配列$/              || # empty array
      value =~ /^(真|肯定|はい|正)$/ || # boolean true
      value =~ /^(偽|否定|いいえ)$/  || # boolean false
      false
    end
    # rubocop:enable all

    def value_number?(value)
      value =~ /^(-|ー)?([0-9０-９]+(\.|．)[0-9０-９]+|[0-9０-９]+)$/
    end

    def value_string?(value)
      value =~ /^「(\\」|[^」])*」$/
    end

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
      chunk =~ /.+とは$/ && eol?(@reader.peek_next_chunk)
    end

    def function_call?(chunk)
      return false unless @current_scope.function? chunk, signature_from_stack(should_consume: false)
      @last_token_type == Token::EOL                                 ||
        (@last_token_type == Token::PARAMETER && !parameter?(chunk)) ||
        (@last_token_type == Token::IF && question?(@reader.peek_next_chunk))
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
      chunk =~ /.+が$/ && variable?(chunk.gsub(/が$/, ''))
    end

    def comp_2?(chunk)
      variable?(chunk) && question?(@reader.peek_next_chunk)
    end

    def comp_2_to?(chunk)
      chunk =~ /.+と$/ && variable?(chunk.gsub(/と$/, ''))
    end

    def comp_2_yori?(chunk)
      chunk =~ /.+より$/ && variable?(chunk.gsub(/より$/, ''))
    end

    def comp_2_gteq?(chunk)
      chunk =~ /.+以上$/ && variable?(chunk.gsub(/以上$/, ''))
    end

    def comp_2_lteq?(chunk)
      chunk =~ /.+以下$/ && variable?(chunk.gsub(/以下$/, ''))
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

    def process_bang(chunk)
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

    def process_variable(chunk)
      # TODO: set sub type (string, int, etc...)

      chunk = sanitize_variable chunk

      token = Token.new Token::VARIABLE, chunk

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

    def process_assignment(chunk)
      name = chunk.gsub(/は$/, '')

      validate_variable_name name

      # TODO: set sub type (numeric index vs key)
      @current_scope.add_variable name
      (@tokens << Token.new(Token::ASSIGNMENT, name)).last
    end

    def process_parameter(chunk)
      (@stack << Token.new(Token::PARAMETER, chunk)).last
    end

    def process_function_def(chunk)
      raise Errors::UnexpectedFunctionDef, chunk if @context.inside_if_condition?

      signature = signature_from_stack

      parameter_names = signature.map { |parameter| parameter[:name] }

      raise Errors::FunctionDefDuplicateParameters if parameter_names != parameter_names.uniq

      parameter_names.each do |parameter|
        raise Errors::FunctionDefPrimitiveParameters if value? parameter
        @tokens << Token.new(Token::PARAMETER, parameter)
      end

      name = chunk.gsub(/とは$/, '')
      validate_function_name name, signature

      token = Token.new Token::FUNCTION_DEF, name
      @tokens << token

      @current_scope.add_function name, signature
      begin_scope Scope::TYPE_FUNCTION_DEF
      parameter_names.each { |parameter| @current_scope.add_variable parameter }

      token
    end

    def process_function_call(chunk)
      destination = @context.inside_if_condition? ? @stack : @tokens

      signature = signature_from_stack
      function = @current_scope.get_function chunk, signature

      function[:signature].each do |signature_parameter|
        call_parameter = signature.slice!(signature.index { |p| p[:particle] == signature_parameter[:particle] })
        # TODO: set sub type (re-use from process_variable)
        name = sanitize_variable call_parameter[:name]
        destination << Token.new(Token::PARAMETER, name)
      end

      (destination << Token.new(Token::FUNCTION_CALL, function[:name])).last
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
      @stack << Token.new(Token::VARIABLE, chunk.gsub(/が$/, ''))
      Token.new Token::COMP_1
    end

    def process_comp_2(chunk)
      @stack << Token.new(Token::VARIABLE, chunk)
      Token.new Token::COMP_2
    end

    def process_comp_2_to(chunk)
      @stack << Token.new(Token::VARIABLE, chunk.gsub(/と$/, ''))
      Token.new Token::COMP_2_TO
    end

    def process_comp_2_yori(chunk)
      @stack << Token.new(Token::VARIABLE, chunk.gsub(/より$/, ''))
      Token.new Token::COMP_2_YORI
    end

    def process_comp_2_gteq(chunk)
      @stack << Token.new(Token::VARIABLE, chunk.gsub(/以上$/, ''))
      Token.new Token::COMP_2_GTEQ
    end

    def process_comp_2_lteq(chunk)
      @stack << Token.new(Token::VARIABLE, chunk.gsub(/以下$/, ''))
      Token.new Token::COMP_2_LTEQ
    end

    def process_comp_3(chunk, options = { reverse?: false })
      case @last_token_type
      when Token::QUESTION
        @stack.pop # drop question
        comparison_tokens = [Token.new(Token::COMP_EQ)]
        comparison_tokens << Token.new(Token::VARIABLE, '真') unless stack_is_comparison?
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

    def process_loop_iterator(_chunk)
      signature = signature_from_stack
      validate_loop_iterator_parameter signature

      parameter = signature.first
      @tokens << Token.new(Token::PARAMETER, parameter[:name])
      (@tokens << Token.new(Token::LOOP_ITERATOR)).last
    end

    def process_loop(_chunk)
      if @stack.size == 2
        parameters = signature_from_stack.sort_by { |parameter| parameter[:name] }
        validate_loop_parameters parameters

        parameters.each do |parameter|
          @tokens << Token.new(Token::PARAMETER, parameter[:name])
        end
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

    def validate_variable_name(name)
      # TODO: disallow other invalid characters
      raise Errors::AssignmentToValue, name if value?(name) && name !~ /^(それ|あれ)$/
      raise Errors::VariableNameReserved, name if reserved_variable_name? name
      raise Errors::VariableNameAlreadyDelcaredAsFunction, name if @current_scope.function? name
    end

    def validate_function_name(name, signature)
      raise Errors::FunctionDefNonVerbName, name unless Conjugator.verb? name
      raise Errors::FunctionDefAlreadyDeclared, name if @current_scope.function? name, signature
      raise Errors::FunctionDefReserved, name if reserved_function_name? name
    end

    def validate_loop_iterator_parameter(signature)
      raise Errors::UnexpectedLoop unless signature.size == 1
      parameter = signature.first
      raise Errors::UnexpectedInput, parameter[:particle] unless parameter[:particle] == 'に'
      raise Errors::InvalidLoopParameter, parameter[:name] unless @current_scope.variable?(parameter[:name]) ||
                                                                  value_string?(parameter[:name])
    end

    def validate_loop_parameters(parameters)
      raise Errors::InvalidLoopParameter, parameters[0][:particle] unless parameters[0][:particle] == 'から'
      raise Errors::InvalidLoopParameter, parameters[1][:particle] unless parameters[1][:particle] == 'まで'
    end

    # Theoretically, the InvalidScope error should never be raised unless the
    # lexer itself has a bug.
    def validate_scope(expected_type, options = { ignore: [] })
      current_scope = @current_scope
      until current_scope.nil? || current_scope.type == expected_type
        unless options[:ignore].include? current_scope.type
          raise Errors::UnexpectedScope.new expected_type, current_scope.type
        end
        current_scope = current_scope.parent
      end
      raise Errors::InvalidScope, expected_type if current_scope.nil?
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

    def begin_scope(type)
      @current_scope = Scope.new @current_scope, type
      @tokens << Token.new(Token::SCOPE_BEGIN)
    end

    def signature_from_stack(options = { should_consume: true })
      signature = @stack.map do |token|
        particle = token.content.match(/(#{PARTICLE})$/)[1]
        { name: token.content.chomp(particle), particle: particle }
      end
      @stack.clear if options[:should_consume]
      signature
    end

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

    def reserved_variable_name?(name)
      %w[
        おおきさ
        大きさ
        ながさ
        長さ
        かず
        数
        底
      ].include? name
    end

    def reserved_function_name?(name)
      loop? name
    end
  end
end
