require_relative '../colour_string.rb'

require_relative 'built_ins.rb'
require_relative 'conjugator.rb'
require_relative 'errors.rb'
require_relative 'scope.rb'
require_relative 'token.rb'

module Tokenizer
  class Lexer
    # rubocop:disable Layout/ExtraSpacing
    PARTICLE     = '(から|と|に|へ|まで|で|を)'.freeze # 使用可能助詞
    COUNTER      = %w[つ 人 個 匹 子 頭].freeze        # 使用可能助数詞
    WHITESPACE   = '[\s　]'.freeze                     # 空白文字
    COMMA        = '[,、]'.freeze
    QUESTION     = '[?？]'.freeze
    BANG         = '[!！]'.freeze
    # rubocop:enable Layout/ExtraSpacing

    TOKEN_SEQUENCE = {
      Token::BOL => [
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

    def initialize(options = {})
      @options = options
      debug_log @options

      @current_indent_level = 0
      @is_inside_block_comment = false
      @is_inside_array = false
      @is_inside_if_statement = false
      @current_scope = Scope.new
      BuiltIns.inject_into @current_scope

      @tokens = []
      @last_token_type = nil
      @peek_next_chunk = nil
      @stack = []
    end

    def tokenize
      File.foreach(@options[:filename]).with_index(1) do |line, line_num|
        begin
          @line = line.gsub(/#{WHITESPACE}*$/, '')
          debug_log 'READ: '.green + @line

          strip_comments

          next if @line.empty?

          process_indent

          @last_token_type = Token::BOL

          process_line

          validate_eol
        rescue LexerError => e
          e.line_num = line_num
          raise
        end
      end

      unindent_to 0

      @tokens
    end

    private

    def debug_log(msg)
      puts msg if @options[:debug]
    end

    def strip_comments
      line = @line
      if @is_inside_block_comment
        if line.index '※'
          line.gsub!(/^.*※/, '')
          @is_inside_block_comment = false
        else
          line.clear
        end
      end

      # TODO: skip block comments inside strings
      line.gsub!(/※.*?※/, '') while line =~ /※.*※/

      # TODO: is whitespace necessary here?
      line = line.gsub(/#{WHITESPACE}*[(（].*$/, '')

      # TODO: skip block comments inside strings
      if line.index '※'
        @is_inside_block_comment = true
        line.gsub!(/※.*$/, '')
      end

      return if line == @line

      debug_log 'STRIP: '.lblue + line
      @line = line
    end

    def process_indent
      return if @is_inside_block_comment
      match_data = @line.match(/^(#{WHITESPACE}+)/)

      if match_data
        indent_level = match_data.captures.first.count '　'
        indent_level += match_data.captures.first.count ' '
      else
        indent_level = 0
      end

      raise UnexpectedIndent if indent_level > @current_indent_level

      unindent_to indent_level if indent_level < @current_indent_level

      @line.gsub!(/^#{WHITESPACE}+/, '')
    end

    def unindent_to(indent_level)
      until @current_indent_level == indent_level do
        @tokens << Token.new(Token::SCOPE_CLOSE)
        @current_indent_level -= 1

        is_alternate_branch = else_if?(peek_next_chunk.to_s) || else?(peek_next_chunk.to_s)
        if @current_scope.is_if_block && !is_alternate_branch
          @current_scope.is_if_block = false
          @tokens << Token.new(Token::SCOPE_CLOSE)
        end

        @current_scope = @current_scope.parent
      end
    end

    def process_line
      until @line.empty? do
        chunk = next_chunk
        debug_log 'CHUNK: '.yellow + chunk

        token = nil
        TOKEN_SEQUENCE[@last_token_type].each do |next_token|
          next unless send "#{next_token}?", chunk

          debug_log next_token
          token = send "process_#{next_token}", chunk
          break
        end

        raise UnexpectedInput, chunk if token.nil?

        @last_token_type = token.type
      end
    end

    # readers

    def next_chunk(options = { should_consume: true })
      split_line = @line.split(/(#{WHITESPACE}|#{QUESTION}|#{BANG}|#{COMMA})/)

      chunk = nil
      until split_line.empty?
        chunk = capture_chunk split_line

        break unless chunk.empty?
      end

      if options[:should_consume]
        @line = split_line.join
        @peek_next_chunk = nil
      end

      chunk.to_s.empty? ? nil : chunk
    end

    def capture_chunk(split_line)
      chunk = split_line.shift.gsub(/^#{WHITESPACE}/, '')

      case chunk
      when /^「[^」]*$/
        raise UnclosedString, chunk + split_line.join unless split_line.join.index '」'
        chunk + capture_string(split_line)
      else
        chunk
      end
    end

    def capture_string(split_line)
      split_line.slice!(0, split_line.join.index(/(?<!\\)」/) + 1).join
    end

    def peek_next_chunk
      @peek_next_chunk ||= next_chunk(should_consume: false)
    end

    # matchers

    # rubocop:disable all
    def value?(value)
      value =~ /^(それ|あれ)$/       || # special
      # TODO: support full-width numbers
      value =~ /^-?(\d+\.\d+|\d+)$/  || # number
      value =~ /^「(\\」|[^」])*」$/ || # string
      value =~ /^配列$/              || # empty array
      value =~ /^(真|肯定|はい|正)$/ || # boolean true
      value =~ /^(偽|否定|いいえ)$/  || # boolean false
      false
    end
    # rubocop:enable all

    def eol?(_chunk)
      false
    end

    def question?(chunk)
      chunk =~ /^#{QUESTION}$/
    end

    def bang?(chunk)
      chunk =~ /^#{BANG}$/
    end

    def comma?(chunk)
      chunk =~ /^#{COMMA}$/
    end

    def variable?(chunk)
      value?(chunk) || @current_scope.variable?(chunk)
    end

    def assignment?(chunk)
      chunk =~ /.+は$/ && !else_if?(chunk)
    end

    def parameter?(chunk)
      chunk =~ /.+#{PARTICLE}$/ && !peek_next_chunk.nil?
    end

    def function_def?(chunk)
      chunk =~ /.+とは$/ && peek_next_chunk.nil?
    end

    def function_call?(chunk)
      return false unless @current_scope.function? chunk, signature_from_stack(should_consume: false)
      @last_token_type == Token::BOL || (
        @last_token_type == Token::PARAMETER &&
        !parameter?(chunk)
      )
    end

    def if?(chunk)
      chunk == 'もし'
    end

    def else_if?(chunk)
      chunk =~ /^(もしくは|または)$/
    end

    def else?(chunk)
      chunk == 'それ以外'
    end

    def comp_1?(chunk)
      chunk =~ /.+が$/ && variable?(chunk.gsub(/が$/, ''))
    end

    def comp_2?(chunk)
      variable?(chunk) && question?(peek_next_chunk.to_s)
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

    def comp_3_eq?(chunk)
      chunk =~ /^(等|ひと)しければ$/
    end

    def comp_3_neq?(chunk)
      chunk =~ /^(等|ひと)しくなければ$/
    end

    # rubocop:disable all
    def comp_3_gt?(chunk)
      chunk =~ /^(大|おお)きければ$/ ||
      chunk =~ /^(長|なが)ければ$/ ||
      chunk =~ /^(高|たか)ければ$/ ||
      chunk =~ /^(多|おお)ければ$/ ||
      false
    end

    def comp_3_lt?(chunk)
      chunk =~ /^(小|ちい)さければ$/ ||
      chunk =~ /^(短|みじか)ければ$/ ||
      chunk =~ /^(低|ひく)ければ$/ ||
      chunk =~ /^(少|すく)なければ$/ ||
      false
    end
    # rubocop:enable all

    def no_op?(chunk)
      chunk == '・・・'
    end

    # processors

    def process_question(chunk)
      token = Token.new Token::QUESTION
      if @is_inside_if_statement
        @stack << token
      else
        raise TrailingCharacters, chunk unless peek_next_chunk.nil?
        @tokens << token
      end
      token
    end

    def process_bang(chunk)
      raise TrailingCharacters, chunk unless peek_next_chunk.nil?
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
      # TODO: set sub type
      token = Token.new Token::VARIABLE, chunk

      if @is_inside_array
        @tokens << token
        check_array_close
      elsif comma? peek_next_chunk.to_s
        @stack << token
      else
        @tokens << token
      end

      token
    end

    def process_assignment(chunk)
      name = chunk.gsub(/は$/, '')
      raise AssignmentToValue, name if value?(name) && name !~ /^(それ|あれ)$/

      # TODO: remove function if @current_scope.function? name
      @current_scope.add_variable name
      (@tokens << Token.new(Token::ASSIGNMENT, name)).last
    end

    def process_parameter(chunk)
      (@stack << Token.new(Token::PARAMETER, chunk)).last
    end

    def process_function_def(chunk)
      signature = signature_from_stack

      parameter_names = signature.map { |parameter| parameter[:name] }

      raise FunctionDefDuplicateParameters if parameter_names != parameter_names.uniq

      parameter_names.each do |parameter|
        raise FunctionDefPrimitiveParameters if value? parameter
        @tokens << Token.new(Token::PARAMETER, parameter)
      end

      name = chunk.gsub(/とは$/, '')
      validate_function_name name, signature

      # TODO: consider spitting out parameters first, then function def
      token = Token.new Token::FUNCTION_DEF, name
      @tokens << token

      @current_scope.add_function name, signature
      enter_scope

      token
    end

    def process_function_call(chunk)
      signature = signature_from_stack

      function = @current_scope.get_function chunk, signature

      function[:signature].each do |signature_parameter|
        call_parameter = signature.slice!(signature.index { |p| p[:particle] == signature_parameter[:particle] })
        # TODO: value?
        @tokens << Token.new(Token::PARAMETER, call_parameter[:name])
      end

      (@tokens << Token.new(Token::FUNCTION_CALL, function[:name])).last
    end

    def process_if(_chunk)
      @is_inside_if_statement = true
      (@tokens << Token.new(Token::IF)).last
    end

    def process_else_if(_chunk)
      raise UnexpectedElseIf unless @current_scope.is_if_block
      @is_inside_if_statement = true
      (@tokens << Token.new(Token::ELSE_IF)).last
    end

    def process_else(_chunk)
      raise UnexpectedElse unless @current_scope.is_if_block
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

    def process_comp_3(_chunk)
      case @last_token_type
      when Token::QUESTION
        @stack.pop # drop question
        if @stack.size == 2 # do comparison
          close_if_statement Token.new Token::COMP_EQ
        else # implicit cast
          close_if_statement
        end
      when Token::COMP_2_LTEQ
        close_if_statement Token.new Token::COMP_LTEQ
      when Token::COMP_2_GTEQ
        close_if_statement Token.new Token::COMP_GTEQ
      end
    end

    def process_comp_3_eq(_chunk)
      close_if_statement Token.new Token::COMP_EQ
    end

    def process_comp_3_neq(_chunk)
      close_if_statement Token.new Token::COMP_NEQ
    end

    def process_comp_3_gt(_chunk)
      close_if_statement Token.new Token::COMP_GT
    end

    def process_comp_3_lt(_chunk)
      close_if_statement Token.new Token::COMP_LT
    end

    def process_no_op(_chunk)
      (@tokens << Token.new(Token::NO_OP)).last
    end

    # helpers

    def check_array_close
      if peek_next_chunk.nil?
        close_array
      elsif !comma?(peek_next_chunk)
        raise TrailingCharacters, 'array'
      end
    end

    def close_array
      @tokens << Token.new(Token::ARRAY_CLOSE)
      @is_inside_array = false
    end

    def enter_scope
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
      raise FunctionDefNonVerbName, name unless Conjugator.verb? name
      raise FunctionDefAlreadyDeclared, name if @current_scope.function? name, signature
    end

    def validate_eol
      return if TOKEN_SEQUENCE[@last_token_type].include?(Token::EOL) && !@is_inside_if_statement
      raise UnexpectedEol
    end

    def close_if_statement(comparator_token = nil)
      @tokens << comparator_token if comparator_token
      @tokens += @stack
      @stack.clear

      @is_inside_if_statement = false
      @current_scope.is_if_block = true

      enter_scope

      Token.new Token::COMP_3
    end
  end
end
