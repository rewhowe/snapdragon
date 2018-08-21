require_relative 'scope.rb'
require_relative 'token.rb'
require_relative 'conjugator.rb'
require_relative 'colour_string.rb'

class Lexer
  # rubocop:disable Layout/ExtraSpacing
  PARTICLE   = '(から|と|に|へ|まで|で|を)'.freeze # 使用可能助詞
  COUNTER    = %w[つ 人 個 匹 子 頭].freeze        # 使用可能助数詞
  WHITESPACE = '[\s　]'.freeze                     # 空白文字
  COMMA      = '[,、]'.freeze
  QUESTION   = '[?？]'.freeze
  BANG       = '[!！]'.freeze
  # rubocop:enable Layout/ExtraSpacing

  TOKEN_SEQUENCE = {
    Token::BOL => [
      Token::EOL,
      Token::COMMENT,
      Token::BLOCK_COMMENT,
      Token::FUNCTION_CALL,
      Token::FUNCTION_DEF,
      Token::INLINE_COMMENT, # TODO: allow these after other tokens as well
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
    Token::INLINE_COMMENT => [
      Token::EOL,
      Token::COMMENT,
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

  class << self
    def tokenize(filename, options = {})
      init options
      puts filename if @options[:debug]

      File.foreach(filename).with_index(1) do |line, line_num|
        begin
          @line = line.gsub(/#{WHITESPACE}*$/, '')
          puts 'READ: '.green + @line if @options[:debug]

          next if @line.empty?

          process_indent

          @last_token_type = Token::BOL

          process_line line_num

          raise "Unexpected EOL on line #{line_num}" unless TOKEN_SEQUENCE[@last_token_type].include? Token::EOL
        rescue => e
          puts "An error occured while tokenizing on line #{line_num}"
          raise e
        end
      end

      @tokens
    end

    private

    def init(options)
      @options = options
      puts @options if @options[:debug]

      @indent_level = 0
      @is_inside_block_comment = false
      @is_inside_array = false
      @current_scope = Scope.new

      @tokens = []
      @last_token_type = nil
      @peek_next_chunk = nil
      @stack = []
    end

    def process_indent
      return unless (match_data = @line.match(/^(#{WHITESPACE})+/))

      indent_level = match_data.captures.first.count '　'
      indent_level += match_data.captures.first.count ' '

      raise 'Unexpected indent' if indent_level > @indent_level

      if indent_level < @indent_level
        until (@expected_index = indent_level) do
          @tokens << Token.new(Token::SCOPE_CLOSE)
          @indent_level -= 1
          @current_scope = @current_scope.parent
        end
      end

      @line.gsub!(/^#{WHITESPACE}+/, '')
    end

    def process_line(line_num)
      until @line.empty? do
        chunk = next_chunk
        puts 'CHUNK: '.yellow + chunk if @options[:debug]

        token = nil
        TOKEN_SEQUENCE[@last_token_type].each do |next_token|
          if send "#{next_token}?", chunk
            token = send "process_#{next_token}", chunk
            break
          end
        end

        raise "Unexpected input on line #{line_num}" if token.nil?

        @last_token_type = token.type
      end
    end

    def next_chunk(should_consume = true)
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
        chunk + capture_string(split_line)
      when /^[(（]/
        chunk + capture_comment(split_line)
      else
        chunk
      end
    end

    def capture_string(split_line)
      # TODO: add tests for this
      raise "Unclosed string (#{split_line.join})" unless split_line.join.index('」')
      split_line.slice!(0, split_line.join.index('」') + 1).join
    end

    def capture_comment(split_line)
      comment = split_line.join
      split_line.clear
      comment
    end

    def peek_next_chunk
      @peek_next_chunk ||= next_chunk false
    end

    # rubocop:disable all
    def value?(value)
      value =~ /^それ|あれ$/        || # special
      value =~ /^-?(\d+\.\d+|\d+)$/ || # number
      value =~ /^「[^」]*」$/       || # string
      value =~ /^配列$/             || # empty array
      value =~ /^真|肯定|はい$/     || # boolean true
      value =~ /^偽|否定|いいえ$/   || # boolean false
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
      chunk =~ /^.+とは$/ && peek_next_chunk.nil?
    end

    def function_call?(chunk)
      return true if @last_token_type == Token::PARAMETER && !parameter?(chunk)
      return true if @last_token_type == Token::BOL && @current_scope.function?(chunk)
      false
    end

    def inline_comment?(chunk)
      chunk =~ /^(\(|（).*$/
    end

    def block_comment?(chunk)
      chunk =~ /^※.*$/
    end

    def comment?(_chunk)
      @is_inside_block_comment
    end

    def no_op?(chunk)
      chunk == '・・・'
    end

    def process_question(_chunk)
      # TODO: needs to be refactored when adding if-statements
      raise 'Trailing characters' unless peek_next_chunk.nil?
      (@tokens << Token.new(Token::QUESTION)).last
    end

    def process_bang(_chunk)
      raise 'Trailing characters' unless peek_next_chunk.nil?
      (@tokens << Token.new(Token::BANG)).last
    end

    def process_comma(_chunk)
      raise 'Unexpected comma' unless @last_token_type == Token::VARIABLE

      unless @is_inside_array
        @tokens << Token.new(Token::ARRAY_BEGIN)
        @tokens << @stack.pop
        @is_inside_array = true
      end

      (@tokens << Token.new(Token::COMMA)).last
    end

    def process_variable(chunk)
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
        @tokens << Token.new(Token::ARRAY_CLOSE)
        @is_inside_array = false
      elsif !comma?(peek_next_chunk)
        raise 'Trailing characters'
      end
    end

    def process_assignment(chunk)
      name = chunk.gsub(/は$/, '')
      (@tokens << Token.new(Token::ASSIGNMENT, name)).last
    end

    def process_parameter(chunk)
      (@stack << Token.new(Token::PARAMETER, chunk)).last
    end

    def process_function_def(chunk)
      raise 'Trailing characters' unless peek_next_chunk.nil?

      signature = signature_from_stack

      signature.each do |parameter|
        # TODO: write test for this (and every other raise)
        raise 'Cannot declare function using primitives for parameters' if value? parameter
        @tokens << Token.new(Token::PARAMETER, parameter[:name])
      end

      name = chunk.gsub(/とは$/, '')
      @current_scope.add_function(name, signature.map { |parameter| parameter[:particle] })
      @current_scope = Scope.new @current_scope
      @indent_level += 1

      @tokens << Token.new(Token::FUNCTION_DEF, name)
      (@tokens << Token.new(Token::SCOPE_BEGIN)).last
    end

    def process_function_call(chunk)
      function = @current_scope.get_function chunk

      signature = signature_from_stack

      function[:signature].each do |particle|
        begin
          parameter = signature.slice!(signature.index { |p| p[:particle] == particle })
          # TODO: value?
          @tokens << Token.new(Token::PARAMETER, parameter[:name])
        rescue
          raise "Missing #{particle} parameter"
        end
      end

      (@tokens << Token.new(Token::FUNCTION_CALL, chunk)).last
    end

    def process_inline_comment(chunk)
      (@tokens << Token.new(Token::INLINE_COMMENT, chunk)).last
    end

    def process_block_comment(chunk)
      (@tokens << Token.new(Token::BLOCK_COMMENT, chunk)).last
    end

    def process_comment(chunk)
      (@tokens << Token.new(Token::COMMENT, chunk)).last
    end

    def process_no_op(chunk)
      (@tokens << Token.new(Token::NO_OP, chunk)).last
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
end
