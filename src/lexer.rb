require_relative 'scope.rb'
require_relative 'token.rb'
require_relative 'conjugator.rb'
require_relative 'colour_string.rb'
require_relative 'built_ins.rb'

class Lexer
  # rubocop:disable Layout/ExtraSpacing
  PARTICLE     = '(から|と|に|へ|まで|で|を)'.freeze # 使用可能助詞
  COUNTER      = %w[つ 人 個 匹 子 頭].freeze        # 使用可能助数詞
  WHITESPACE   = '[\s　]'.freeze                     # 空白文字
  COMMA        = '[,、]'.freeze
  QUESTION     = '[?？]'.freeze
  BANG         = '[!！]'.freeze
  COMMENT_MARK = '[(（※]'.freeze
  # rubocop:enable Layout/ExtraSpacing

  TOKEN_SEQUENCE = {
    Token::BOL => [
      Token::EOL,
      Token::COMMENT,
      Token::BLOCK_COMMENT,
      Token::FUNCTION_CALL,
      Token::FUNCTION_DEF,
      # TODO: remove all of the comment stuff (just ignore it; treat like EOL)
      Token::INLINE_COMMENT,
      Token::NO_OP,
      Token::ASSIGNMENT,
      Token::PARAMETER,
      Token::IF,
      # Token::ELSE_IF,
      # Token::ELSE,
    ],
    Token::ASSIGNMENT => [
      Token::VARIABLE,
    ],
    Token::VARIABLE => [
      Token::EOL,
      Token::QUESTION,
      Token::COMMA,
      Token::INLINE_COMMENT,
    ],
    Token::PARAMETER => [
      Token::PARAMETER,
      Token::FUNCTION_DEF,
      Token::FUNCTION_CALL,
    ],
    Token::FUNCTION_DEF => [
      Token::EOL,
      Token::INLINE_COMMENT,
    ],
    Token::FUNCTION_CALL => [
      Token::EOL,
      Token::INLINE_COMMENT,
      Token::QUESTION,
      Token::BANG,
    ],
    Token::INLINE_COMMENT => [
      Token::EOL,
    ],
    Token::BLOCK_COMMENT => [
      Token::EOL,
      Token::COMMENT,
    ],
    Token::COMMENT => [
      Token::EOL,
      Token::BLOCK_COMMENT,
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
      # TODO: Token::QUESTION,
    ],
    Token::COMMA => [
      Token::VARIABLE,
    ],
    Token::IF => [
      Token::PARAMETER,
      Token::COMP_1,
      Token::COMP_2,
    ],
    # Token::ELSE_IF => [ # in process_line if current_scope.is_if_block and peek next != else
    #                    set is_if_block false
    #                    when matching: check current_scope.is_if_block
    #   Token::PARAMETER,
    #   Token::COMP_1,
    #   Token::COMP_2,
    # ],
    # Token::ELSE => [ # in process_line if current_scope.is_if_block and peek next != else
    #                    set is_if_block false
    #                    when matching: check current_scope.is_if_block
    #   Token::EOL,
    # ],
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
    puts @options if @options[:debug]

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

  def tokenize(filename)
    puts filename if @options[:debug]

    File.foreach(filename).with_index(1) do |line, line_num|
      begin
        @line = line.gsub(/#{WHITESPACE}*$/, '')
        puts 'READ: '.green + @line if @options[:debug]

        next if @line.empty?

        process_indent

        @last_token_type = Token::BOL

        process_line line_num

        validate_eol line_num
      rescue => e
        # raise e, "An error occured while tokenizing on line #{line_num}".red, e.backtrace
        raise e
      end
    end

    unindent_to 0

    @tokens
  end

  private

  def process_indent
    return if @is_inside_block_comment
    match_data = @line.match(/^(#{WHITESPACE}+)/)

    if match_data
      indent_level = match_data.captures.first.count '　'
      indent_level += match_data.captures.first.count ' '
    else
      indent_level = 0
    end

    raise 'Unexpected indent' if indent_level > @current_indent_level

    unindent_to indent_level if indent_level < @current_indent_level

    @line.gsub!(/^#{WHITESPACE}+/, '')
  end

  def unindent_to(indent_level)
    until @current_indent_level == indent_level do
      @tokens << Token.new(Token::SCOPE_CLOSE)
      @current_indent_level -= 1

      if @current_scope.is_if_block
        @current_scope.is_if_block = false
        @tokens << Token.new(Token::SCOPE_CLOSE)
      end

      @current_scope = @current_scope.parent
    end
  end

  def process_line(line_num)
    until @line.empty? do
      chunk = next_chunk
      puts 'CHUNK: '.yellow + chunk if @options[:debug]

      token = nil
      TOKEN_SEQUENCE[@last_token_type].each do |next_token|
        next unless send "#{next_token}?", chunk

        puts next_token if @options[:debug]
        token = send "process_#{next_token}", chunk
        break
      end

      raise "Unexpected input on line #{line_num}: #{chunk}" if token.nil?

      @last_token_type = token.type
    end
  end

  # readers

  def next_chunk(should_consume = true)
    split_line = @line.split(/(#{WHITESPACE}|#{QUESTION}|#{BANG}|#{COMMA}|#{COMMENT_MARK})/)

    chunk = nil
    until split_line.empty?
      chunk = capture_chunk split_line

      break unless chunk.empty?
    end

    if should_consume
      @line = split_line.join
      @peek_next_chunk = nil
    end

    chunk.to_s.empty? ? nil : chunk
  end

  def capture_chunk(split_line)
    chunk = split_line.shift.gsub(/^#{WHITESPACE}/, '')

    case chunk
    when /^「[^」]*$/
      raise "Unclosed string (#{chunk + split_line.join})" unless split_line.join.index('」')
      chunk + capture_string(split_line)
    when /^#{COMMENT_MARK}/
      chunk + capture_comment(split_line)
    else
      chunk
    end
  end

  def capture_string(split_line)
    split_line.slice!(0, split_line.join.index(/(?<!\\)」/) + 1).join
  end

  def capture_comment(split_line)
    comment = split_line.join
    split_line.clear
    comment
  end

  def peek_next_chunk
    @peek_next_chunk ||= next_chunk false
  end

  # matchers

  # rubocop:disable all
  def value?(value)
    value =~ /^それ|あれ$/           || # special
    # TODO: support full-width numbers
    value =~ /^-?(\d+\.\d+|\d+)$/    || # number
    value =~ /^「(\\」|[^」])*」$/   || # string
    value =~ /^配列$/                || # empty array
    value =~ /^真|正|肯定|はい$/     || # boolean true
    value =~ /^偽|不正|否定|いいえ$/ || # boolean false
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
    chunk =~ /.+(?<!また|もしく)は$/
  end

  def parameter?(chunk)
    chunk =~ /.+#{PARTICLE}$/ && !peek_next_chunk.nil?
  end

  def function_def?(chunk)
    chunk =~ /.+とは$/ && (peek_next_chunk.nil? || inline_comment?(peek_next_chunk))
  end

  def function_call?(chunk)
    return false unless @current_scope.function? chunk
    @last_token_type == Token::BOL || (
      @last_token_type == Token::PARAMETER &&
      !parameter?(chunk)
    )
  end

  def if?(chunk)
    chunk == 'もし'
  end

  # def else_if?(chunk)
  # end

  # def else?(chunk)
  # end

  # TODO: check variable?
  def comp_1?(chunk)
    chunk =~ /.+が$/
  end

  def comp_2?(chunk)
    variable?(chunk) && question?(peek_next_chunk.to_s)
  end

  def comp_2_to?(chunk)
    chunk =~ /.+と$/
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

  def inline_comment?(chunk)
    chunk =~ /^[(（]/
  end

  def block_comment?(chunk)
    chunk =~ /^※/
  end

  def comment?(chunk)
    !block_comment?(chunk) && @is_inside_block_comment
  end

  def no_op?(chunk)
    chunk == '・・・'
  end

  # processors

  def process_question(_chunk)
    token = Token.new(Token::QUESTION)
    if @is_inside_if_statement
      @stack << token
    else
      raise 'Trailing characters after question' unless peek_next_chunk.nil?
      @tokens << token
    end
    token
  end

  def process_bang(_chunk)
    raise 'Trailing characters after bang' unless peek_next_chunk.nil?
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
    elsif comma?(peek_next_chunk.to_s)
      @stack << token
    else
      @tokens << token
    end

    token
  end

  def process_assignment(chunk)
    name = chunk.gsub(/は$/, '')
    raise "Cannot assign to a value (#{name})" if value?(name) && name !~ /それ|あれ/

    # TODO: remove function if @current_scope.function? name
    @current_scope.add_variable name
    (@tokens << Token.new(Token::ASSIGNMENT, name)).last
  end

  def process_parameter(chunk)
    # TODO: strip particle?
    (@stack << Token.new(Token::PARAMETER, chunk)).last
  end

  def process_function_def(chunk)
    signature = signature_from_stack

    signature.each do |parameter|
      raise 'Cannot declare function using primitives for parameters' if value? parameter
      @tokens << Token.new(Token::PARAMETER, parameter[:name])
    end

    name = chunk.gsub(/とは$/, '')
    raise "Function declaration does not look like a verb (#{name})" unless Conjugator.verb? name

    # TODO: consider spitting out parameters first, then function def
    token = Token.new Token::FUNCTION_DEF, name
    @tokens << token

    @current_scope.add_function name, signature
    enter_scope

    token
  end

  def process_function_call(chunk)
    function = @current_scope.get_function chunk

    signature = signature_from_stack

    function[:signature].each do |particle|
      begin
        parameter = signature.slice!(signature.index { |p| p[:particle] == particle[:particle] })
        # TODO: value?
        @tokens << Token.new(Token::PARAMETER, parameter[:name])
      rescue => e
        raise "Missing #{particle} parameter\n#{e}"
      end
    end

    (@tokens << Token.new(Token::FUNCTION_CALL, function[:name])).last
  end

  def process_if(_chunk)
    @is_inside_if_statement = true
    (@tokens << Token.new(Token::IF)).last
  end

  # def process_else_if(chunk)
  # end

  # def process_else(chunk)
  # end

  def process_comp_1(chunk)
    @stack << Token.new(Token::VARIABLE, chunk.gsub(/が$/, ''))
    Token.new(Token::COMP_1)
  end

  def process_comp_2(chunk)
    @stack << Token.new(Token::VARIABLE, chunk)
    Token.new(Token::COMP_2)
  end

  def process_comp_2_to(chunk)
    @stack << Token.new(Token::VARIABLE, chunk.gsub(/と$/, ''))
    Token.new(Token::COMP_2_TO)
  end

  def process_comp_2_yori(chunk)
    @stack << Token.new(Token::VARIABLE, chunk.gsub(/より$/, ''))
    Token.new(Token::COMP_2_YORI)
  end

  def process_comp_2_gteq(chunk)
    @stack << Token.new(Token::VARIABLE, chunk.gsub(/以上$/, ''))
    Token.new(Token::COMP_2_GTEQ)
  end

  def process_comp_2_lteq(chunk)
    @stack << Token.new(Token::VARIABLE, chunk.gsub(/以下$/, ''))
    Token.new(Token::COMP_2_LTEQ)
  end

  def process_comp_3(_chunk)
    case @last_token_type
    when Token::QUESTION
      if @tokens.last.type == Token::FUNCTION_CALL
        @tokens << @stack.pop # store question
        close_if_statement
      else
        @stack.pop # drop question
        close_if_statement Token.new Token::COMP_EQ
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

  def process_inline_comment(chunk)
    close_array if @is_inside_array
    comment = chunk.gsub(/^#{COMMENT_MARK}/, '')
    (@tokens << Token.new(Token::INLINE_COMMENT, comment)).last
  end

  def process_block_comment(chunk)
    @is_inside_block_comment = !@is_inside_block_comment
    comment = chunk.gsub(/^#{COMMENT_MARK}/, '')
    (@tokens << Token.new(Token::BLOCK_COMMENT, comment)).last
  end

  def process_comment(chunk)
    (@tokens << Token.new(Token::COMMENT, chunk)).last
  end

  def process_no_op(_chunk)
    (@tokens << Token.new(Token::NO_OP)).last
  end

  # helpers

  def check_array_close
    if peek_next_chunk.nil?
      close_array
    elsif !(comma?(peek_next_chunk) || inline_comment?(peek_next_chunk))
      raise "Trailing characters in array declaration: #{peek_next_chunk}"
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

  def signature_from_stack
    signature = @stack.map do |token|
      parameter = token.content.match(/(.+)(#{PARTICLE})$/)
      { name: parameter[1], particle: parameter[2] }
    end
    @stack.clear
    signature
  end

  def validate_eol(line_num)
    return if TOKEN_SEQUENCE[@last_token_type].include? Token::EOL
    return unless @is_inside_if_statement
    raise "Unexpected EOL on line #{line_num}"
  end

  def close_if_statement(comparator_token = nil)
    if comparator_token
      @tokens << comparator_token
      @tokens += @stack
      @stack.clear
    end

    @is_inside_if_statement = false
    @current_scope.is_if_block = true

    enter_scope

    Token.new Token::COMP_3
  end
end
