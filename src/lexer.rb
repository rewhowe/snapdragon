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
  # COMMENT_MARK = '[(（※]'.freeze
  # rubocop:enable Layout/ExtraSpacing

  TOKEN_SEQUENCE = {
    Token::BOL => [
      Token::EOL,
      # Token::COMMENT,
      # Token::BLOCK_COMMENT,
      Token::FUNCTION_CALL,
      Token::FUNCTION_DEF,
      # Token::INLINE_COMMENT,
      Token::NO_OP,
      Token::ASSIGNMENT,
      Token::PARAMETER,
    ],
    Token::ASSIGNMENT => [
      Token::VARIABLE,
    ],
    Token::VARIABLE => [
      Token::EOL,
      Token::QUESTION,
      Token::COMMA,
      # Token::INLINE_COMMENT,
    ],
    Token::PARAMETER => [
      Token::PARAMETER,
      Token::FUNCTION_DEF,
      Token::FUNCTION_CALL,
    ],
    Token::FUNCTION_DEF => [
      Token::EOL,
      # Token::INLINE_COMMENT,
    ],
    Token::FUNCTION_CALL => [
      Token::EOL,
      # Token::INLINE_COMMENT,
      Token::QUESTION,
      Token::BANG,
    ],
    # Token::INLINE_COMMENT => [
    #   Token::EOL,
    # ],
    # Token::BLOCK_COMMENT => [
    #   Token::EOL,
    #   Token::COMMENT,
    # ],
    # Token::COMMENT => [
    #   Token::EOL,
    #   Token::BLOCK_COMMENT,
    # ],
    Token::NO_OP => [
      Token::EOL,
    ],
    Token::QUESTION => [
      Token::EOL,
    ],
    Token::BANG => [
      Token::EOL,
    ],
    Token::COMMA => [
      Token::VARIABLE,
    ],
    Token::SCOPE_BEGIN => [
      Token::EOL,
    ],
  }.freeze

  def initialize(options = {})
    @options = options
    puts @options if @options[:debug]

    @current_indent_level = 0
    @is_inside_block_comment = false
    @is_inside_array = false
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

        strip_comments

        next if @line.empty?

        process_indent

        @last_token_type = Token::BOL

        process_line line_num

        raise "Unexpected EOL on line #{line_num}" unless TOKEN_SEQUENCE[@last_token_type].include? Token::EOL
      rescue => e
        raise "An error occured while tokenizing on line #{line_num}\n#{e}"
      end
    end

    unindent_to 0

    @tokens
  end

  private

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

    line.gsub!(/※.*?※/, '') while line =~ /※.*※/

    line = line.gsub(/#{WHITESPACE}*[(（].*$/, '')

    if line.index '※'
      @is_inside_block_comment = true
      line.gsub!(/※.*$/, '')
    end

    return if line == @line

    puts 'STRIP: '.lblue + line if @options[:debug]
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

    raise 'Unexpected indent' if indent_level > @current_indent_level

    unindent_to indent_level if indent_level < @current_indent_level

    @line.gsub!(/^#{WHITESPACE}+/, '')
  end

  def unindent_to(indent_level)
    until @current_indent_level == indent_level do
      @tokens << Token.new(Token::SCOPE_CLOSE)
      @current_indent_level -= 1
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

  def next_chunk(should_consume = true)
    # split_line = @line.split(/(#{WHITESPACE}|#{QUESTION}|#{BANG}|#{COMMA}|#{COMMENT_MARK})/)
    split_line = @line.split(/(#{WHITESPACE}|#{QUESTION}|#{BANG}|#{COMMA})/)

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
    # when /^#{COMMENT_MARK}/
    #   chunk + capture_comment(split_line)
    else
      chunk
    end
  end

  def capture_string(split_line)
    split_line.slice!(0, split_line.join.index(/(?<!\\)」/) + 1).join
  end

  # def capture_comment(split_line)
  #   comment = split_line.join
  #   split_line.clear
  #   comment
  # end

  def peek_next_chunk
    @peek_next_chunk ||= next_chunk false
  end

  # rubocop:disable all
  def value?(value)
    value =~ /^(それ|あれ)$/       || # special
    # TODO: support full-width numbers
    value =~ /^-?(\d+\.\d+|\d+)$/  || # number
    value =~ /^「(\\」|[^」])*」$/ || # string
    value =~ /^配列$/              || # empty array
    value =~ /^真|肯定|はい$/      || # boolean true
    value =~ /^偽|否定|いいえ$/    || # boolean false
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
    chunk =~ /^.+は$/ && !peek_next_chunk.nil?
  end

  def parameter?(chunk)
    chunk =~ /^.+#{PARTICLE}$/ && !peek_next_chunk.nil?
  end

  def function_def?(chunk)
    chunk =~ /^.+とは$/ && (peek_next_chunk.nil? || inline_comment?(peek_next_chunk))
  end

  def function_call?(chunk)
    return false unless @current_scope.function? chunk
    @last_token_type == Token::BOL || (
      @last_token_type == Token::PARAMETER &&
      !parameter?(chunk)
    )
  end

  def inline_comment?(chunk)
    chunk =~ /^[(（].*$/
  end

  def block_comment?(chunk)
    chunk =~ /^※.*$/
  end

  def comment?(chunk)
    !block_comment?(chunk) && @is_inside_block_comment
  end

  def no_op?(chunk)
    chunk == '・・・'
  end

  def process_question(_chunk)
    # TODO: needs to be refactored when adding if-statements
    raise 'Trailing characters after question' unless peek_next_chunk.nil?
    (@tokens << Token.new(Token::QUESTION)).last
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
    token = Token.new(Token::VARIABLE, chunk)

    if @is_inside_array
      @tokens << token
      check_array_close
    elsif peek_next_chunk && comma?(peek_next_chunk)
      @stack << token
    else
      @tokens << token
    end

    token
  end

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

  def process_assignment(chunk)
    name = chunk.gsub(/は$/, '')
    if value?(name) && !(name =~ /それ|あれ/)
      raise "Cannot assign to a value (#{name})"
    end
    # TODO: remove function if @current_scope.function? name
    @current_scope.add_variable name
    (@tokens << Token.new(Token::ASSIGNMENT, name)).last
  end

  def process_parameter(chunk)
    (@stack << Token.new(Token::PARAMETER, chunk)).last
  end

  def process_function_def(chunk)
    signature = signature_from_stack

    signature.each do |parameter|
      raise 'Cannot declare function using primitives for parameters' if value? parameter
      @tokens << Token.new(Token::PARAMETER, parameter[:name])
    end

    name = chunk.gsub(/とは$/, '')
    raise "Function delcaration does not look like a verb (#{name})" unless Conjugator.verb? name

    @current_scope.add_function name, signature
    @current_scope = Scope.new @current_scope
    @current_indent_level += 1

    # TODO: consider spitting out parameters first, then function def
    token = Token.new(Token::FUNCTION_DEF, name)
    @tokens += [token, Token.new(Token::SCOPE_BEGIN)]
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

  # def process_inline_comment(chunk)
  #   close_array if @is_inside_array
  #   comment = chunk.gsub(/^#{COMMENT_MARK}/, '')
  #   (@tokens << Token.new(Token::INLINE_COMMENT, comment)).last
  # end

  # def process_block_comment(chunk)
  #   @is_inside_block_comment = !@is_inside_block_comment
  #   comment = chunk.gsub(/^#{COMMENT_MARK}/, '')
  #   (@tokens << Token.new(Token::BLOCK_COMMENT, comment)).last
  # end

  # def process_comment(chunk)
  #   (@tokens << Token.new(Token::COMMENT, chunk)).last
  # end

  def process_no_op(_chunk)
    (@tokens << Token.new(Token::NO_OP)).last
  end

  def signature_from_stack
    signature = @stack.map do |token|
      parameter = token.content.match(/(.+)(#{PARTICLE})$/)
      { name: parameter[1], particle: parameter[2] }
    end
    @stack.clear
    signature
  end
end
