require_relative '../colour_string.rb'
require_relative '../util/logger.rb'

require_relative 'built_ins.rb'
require_relative 'conjugator.rb'
require_relative 'errors.rb'
require_relative 'scope.rb'
require_relative 'token.rb'
require_relative 'reader.rb'

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
        Token::COMP_3_NOT,
      ],
      Token::BANG => [
        Token::EOL,
      ],
      Token::COMMA => [
        Token::VARIABLE,
      ],
      Token::IF => [
        Token::PARAMETER,
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
        Token::COMP_3_EQ, # == COMP_3
        Token::COMP_3_NEQ, # == COMP_3
      ],
      Token::COMP_2_YORI => [
        Token::COMP_3_LT, # == COMP_3
        Token::COMP_3_GT, # == COMP_3
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
    }.freeze

    def initialize(reader = Reader.new, options = {})
      @reader  = reader
      @options = options

      @current_indent_level   = 0
      @is_inside_array        = false
      @is_inside_if_statement = false
      @current_scope          = Scope.new
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
        Logger::debug 'READ: '.green + "\"#{chunk}\""

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

        Logger::debug 'MATCH: '.yellow + valid_token.to_s
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
      # TODO: support full-width numbers [１~０]
      value =~ /^-?(\d+\.\d+|\d+)$/  || # number
      value =~ /^「(\\」|[^」])*」$/ || # string
      value =~ /^配列$/              || # empty array
      value =~ /^(真|肯定|はい|正)$/ || # boolean true
      value =~ /^(偽|否定|いいえ)$/  || # boolean false
      false
    end
    # rubocop:enable all

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
      @last_token_type == Token::EOL ||
        (@last_token_type == Token::PARAMETER && !parameter?(chunk))
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
      raise Errors::UnexpectedEol if @is_inside_if_statement
      process_indent
      Token.new Token::EOL
    end

    def process_indent
      next_chunk = @reader.peek_next_chunk skip_whitespace?: false
      return if (whitespace?(next_chunk) && eol?(@reader.peek_next_chunk)) || # next line is pure whitespace
                eol?(next_chunk)                                              # next line is empty

      indent_level = next_chunk.length - next_chunk.gsub(/[#{WHITESPACE}]/, '').length

      raise Errors::UnexpectedIndent if indent_level > @current_indent_level

      unindent_to indent_level if indent_level < @current_indent_level
    end

    def process_question(chunk)
      token = Token.new Token::QUESTION
      if @is_inside_if_statement
        @stack << token
      else
        raise Errors::TrailingCharacters, chunk unless eol?(@reader.peek_next_chunk)
        @tokens << token
      end
      token
    end

    def process_bang(chunk)
      raise Errors::TrailingCharacters, chunk unless eol?(@reader.peek_next_chunk)
      (@tokens << Token.new(Token::BANG)).last
    end

    def process_comma(_chunk)
      unless @is_inside_array
        @tokens << Token.new(Token::ARRAY_BEGIN)
        @tokens << @stack.pop
        @is_inside_array = true
      end

      (@tokens << Token.new(Token::COMMA)).last
    end

    def process_variable(chunk)
      # TODO: set sub type (string, int, etc...)
      token = Token.new Token::VARIABLE, chunk

      if @is_inside_array
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
      raise Errors::AssignmentToValue, name if value?(name) && name !~ /^(それ|あれ)$/

      # TODO: need to handle variables with the same names as functions
      @current_scope.add_variable name
      (@tokens << Token.new(Token::ASSIGNMENT, name)).last
    end

    def process_parameter(chunk)
      (@stack << Token.new(Token::PARAMETER, chunk)).last
    end

    def process_function_def(chunk)
      raise Errors::UnexpectedFunctionDef, chunk if @is_inside_if_statement

      signature = signature_from_stack

      parameter_names = signature.map { |parameter| parameter[:name] }

      raise Errors::FunctionDefDuplicateParameters if parameter_names != parameter_names.uniq

      parameter_names.each do |parameter|
        raise Errors::FunctionDefPrimitiveParameters if value? parameter
        @tokens << Token.new(Token::PARAMETER, parameter)
      end

      name = chunk.gsub(/とは$/, '')
      validate_function_name name, signature

      # TODO: consider spitting out parameters first, then function def
      token = Token.new Token::FUNCTION_DEF, name
      @tokens << token

      @current_scope.add_function name, signature
      begin_scope

      token
    end

    def process_function_call(chunk)
      destination = @is_inside_if_statement ? @stack : @tokens

      signature = signature_from_stack
      function = @current_scope.get_function chunk, signature

      function[:signature].each do |signature_parameter|
        call_parameter = signature.slice!(signature.index { |p| p[:particle] == signature_parameter[:particle] })
        # TODO: set sub type (re-use from process_variable)
        destination << Token.new(Token::PARAMETER, call_parameter[:name])
      end

      (destination << Token.new(Token::FUNCTION_CALL, function[:name])).last
    end

    def process_if(_chunk)
      @is_inside_if_statement = true
      (@tokens << Token.new(Token::IF)).last
    end

    def process_else_if(_chunk)
      raise Errors::UnexpectedElseIf unless @current_scope.is_if_block
      @is_inside_if_statement = true
      (@tokens << Token.new(Token::ELSE_IF)).last
    end

    def process_else(_chunk)
      raise Errors::UnexpectedElse unless @current_scope.is_if_block
      token = Token.new Token::ELSE
      @tokens << token
      close_if_statement
      token
    end

    def process_comp_1(chunk)
      @stack << Token.new(Token::VARIABLE, chunk.gsub(/が$/, ''))
      Token.new Token::COMP_1
    end

    # TODO: let's combine all comp_2 and comp_3 into a single token type with a sub type
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
        if stack_is_comparison?
          close_if_statement [Token.new(options[:reverse?] ? Token::COMP_NEQ : Token::COMP_EQ)]
        else # boolean cast of a function call or variable
          close_if_statement [
            Token.new(Token::COMP_EQ),
            Token.new(Token::VARIABLE, options[:reverse?] ? '偽' : '真'),
          ]
        end
      when Token::COMP_2_LTEQ
        close_if_statement [Token.new(options[:reverse?] ? Token::COMP_GT : Token::COMP_LTEQ)]
      when Token::COMP_2_GTEQ
        close_if_statement [Token.new(options[:reverse?] ? Token::COMP_LT : Token::COMP_GTEQ)]
      else
        raise Errors::UnexpectedInput, chunk
      end
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

    def process_no_op(_chunk)
      (@tokens << Token.new(Token::NO_OP)).last
    end

    # helpers

    def unindent_to(indent_level)
      until @current_indent_level == indent_level do
        @tokens << Token.new(Token::SCOPE_CLOSE)
        @current_indent_level -= 1

        is_alternate_branch = else_if?(@reader.peek_next_chunk) || else?(@reader.peek_next_chunk)
        if @current_scope.is_if_block && !is_alternate_branch
          @current_scope.is_if_block = false
          @tokens << Token.new(Token::SCOPE_CLOSE)
        end

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
      @is_inside_array = false
    end

    def begin_scope
      @current_scope = Scope.new @current_scope
      @current_indent_level += 1
      @tokens << Token.new(Token::SCOPE_BEGIN)
    end

    def signature_from_stack(options = { should_consume: true })
      signature = @stack.map do |token|
        parameter = token.content.match(/(.+)(#{PARTICLE})$/)
        { name: parameter[1], particle: parameter[2] }
      end
      @stack.clear if options[:should_consume]
      signature
    end

    def validate_function_name(name, signature)
      raise Errors::FunctionDefNonVerbName, name unless Conjugator.verb? name
      # TODO: this could be deleted (validation not necessary at this point; also large programs could be troublesome)
      raise Errors::FunctionDefAlreadyDeclared, name if @current_scope.function? name, signature
    end

    def stack_is_comparison?
      @stack.size == 2 && @stack.all? { |token| token.type == Token::VARIABLE }
    end

    def close_if_statement(comparator_tokens = [])
      @tokens += comparator_tokens unless comparator_tokens.empty?
      @tokens += @stack
      @stack.clear

      @is_inside_if_statement = false
      @current_scope.is_if_block = true

      begin_scope

      Token.new Token::COMP_3
    end
  end
end
