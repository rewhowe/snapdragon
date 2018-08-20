require_relative File.join('scope.rb')
require_relative File.join('token.rb')
require_relative File.join('conjugator.rb')
require_relative File.join('colour_string.rb')

class Lexer
  PARTICLE   = '(から|と|に|へ|まで|で|を)'.freeze # 使用可能助詞
  COUNTER    = %w(つ 人 個 匹 子 頭).freeze        # 使用可能助数詞
  WHITESPACE = '[\s　]'.freeze                     # 空白文字
  COMMA      = '[,、]'.freeze
  QUESTION   = '[?？]'.freeze
  BANG       = '[!！]'.freeze

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
  }

  class << self

    def tokenize(filename, options)
      init options
      puts filename if @options[:debug]

      File.foreach(filename).with_index(1) do |line, line_num|
        begin
          @line = line.gsub(/#{WHITESPACE}*$/, '')
          puts 'READ: '.green + @line if @options[:debug]

          next if @line.empty?

          process_indent

          @last_token_type = Token::BOL

          until @line.empty? do
            chunk = get_next_chunk
            puts 'CHUNK: '.yellow + chunk if @options[:debug]

            token = nil
            TOKEN_SEQUENCE[@last_token_type].each do |next_token|
              if send "is_#{next_token}?", chunk
                token = send "process_#{next_token}", chunk
                break
              end
            end

            if token
              @last_token_type = token.type
            else
              error "Unexpected input on line #{line_num}" if token.nil?
            end
          end

          unless TOKEN_SEQUENCE[@last_token_type].include? Token::EOL
            error "Unexpected EOL on line #{line_num}"
          end

        rescue => e
          raise e unless @options[:debug]
          puts "An error occured while tokenizing on line #{line_num}"
          puts e.message
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
      @stack = []
    end

    def error(message, level=nil)
      if @options[:debug]
        puts message.red
      end
      return unless level == :critical
      raise message
    end

    def is_value?(value)
      value =~ /^それ|あれ$/        || # special
      value =~ /^-?(\d+\.\d+|\d+)$/ || # number
      value =~ /^「[^」]*」$/       || # string
      value =~ /^配列$/             || # empty array
      value =~ /^真|肯定|はい$/     || # boolean true
      value =~ /^偽|否定|いいえ$/   || # boolean false
      false
    end

    def process_indent
      return unless match_data = @line.match(/^(#{WHITESPACE})+/)

      indent_level = match_data.captures.first.count '　'
      indent_level += match_data.captures.first.count ' '

      if indent_level > @indent_level
        error 'Unexpected indent', :critical
      elsif indent_level < @indent_level
        until @expected_index = indent_level do
          @tokens << Token.new(Token::SCOPE_CLOSE)
          @indent_level -= 1
          @current_scope = @current_scope.parent
        end
      end

      @line.gsub!(/^#{WHITESPACE}+/, '')
    end

    def get_next_chunk(should_consume=true)
      split_line = @line.split(/(#{WHITESPACE}|#{QUESTION}|#{BANG}|#{COMMA})/)

      chunk = nil
      until split_line.empty?
        chunk = split_line.shift.gsub(/^#{WHITESPACE}/, '')

        next if chunk.empty?

        if chunk =~ /^「.*[^」]$/
          error 'Unclosed string' unless split_line.join.index('」')
          chunk += split_line.slice!(0, split_line.join.index('」') + 1).join
        end

        break
      end

      @line = split_line.join if should_consume

      chunk.to_s.empty? ? nil : chunk
    end

    def peek_next_chunk
      # TODO: save peeked chunk until the next time get chunk is called
      get_next_chunk false
    end

    def is_EOL?(chunk)
      false
    end

    def is_QUESTION?(chunk)
      chunk =~ /^#{QUESTION}$/
    end

    def is_BANG?(chunk)
      chunk =~ /^#{BANG}$/
    end

    def is_COMMA?(chunk)
      chunk =~ /^#{COMMA}$/
    end

    def is_VARIABLE?(chunk)
      is_value?(chunk) || @current_scope.variable?(chunk)
    end

    def is_ASSIGNMENT?(chunk)
      chunk =~ /^.+は$/ && !peek_next_chunk.nil?
    end

    def is_PARAMETER?(chunk)
      chunk =~ /^.+#{PARTICLE}$/ && !peek_next_chunk.nil?
    end

    def is_FUNCTION_DEF?(chunk)
      chunk =~ /^.+とは$/ && peek_next_chunk.nil?
    end

    def is_FUNCTION_CALL?(chunk)
      return true if @last_token_type === Token::PARAMETER && !is_PARAMETER(chunk)
      return true if @last_token_type === Token::BOL && @current_scope.function?(chunk)
      false
    end

    def is_INLINE_COMMENT?(chunk)
      chunk =~ /^(\(|（).*$/
    end

    def is_BLOCK_COMMENT?(chunk)
      chunk =~ /^※.*$/
    end

    def is_COMMENT?(chunk)
      @is_inside_block_comment
    end

    def is_NO_OP?(chunk)
      chunk == '・・・'
    end

    def process_QUESTION(chunk)
      # TODO: needs to be refactored when adding if-statements
      error 'Trailing characters', :critical unless peek_next_chunk.nil?
      (@tokens << Token.new(Token::QUESTION)).last
    end

    def process_BANG(chunk)
      error 'Trailing characters', :critical unless peek_next_chunk.nil?
      (@tokens << Token.new(Token::BANG)).last
    end

    def process_COMMA(chunk)
      error 'Unexpected comma' unless @last_token_type == Token::VARIABLE

      unless @is_inside_array
        @tokens << Token.new(Token::ARRAY_BEGIN)
        @tokens << @stack.pop
        @is_inside_array = true
      end

      (@tokens << Token.new(Token::COMMA)).last
    end

    def process_VARIABLE(chunk)
      token = Token.new(Token::VARIABLE, chunk)

      if @is_inside_array
        @tokens << token

        if peek_next_chunk.nil?
          @tokens << Token::new(Token::ARRAY_CLOSE)
          @is_inside_array = false
        elsif !is_COMMA?(peek_next_chunk)
          error 'Trailing characters', :critical unless peek_next_chunk.nil?
        end
      elsif peek_next_chunk && is_COMMA?(peek_next_chunk)
        @stack << token
      else
        @tokens << token
      end

      token
    end

    def process_ASSIGNMENT(chunk)
      name = chunk.gsub(/は$/, '')
      (@tokens << Token.new(Token::ASSIGNMENT, name)).last
    end

    def process_PARAMETER(chunk)
      (@stack << Token.new(Token::PARAMETER, chunk)).last
    end

    def process_FUNCTION_DEF(chunk)
      error 'Trailing characters', :critical unless peek_next_chunk.nil?

      signature = get_signature_from_stack

      signature.each do |parameter|
        @tokens << Token.new(Token::PARAMETER, parameter[:name])
      end

      name = chunk.gsub(/とは$/), ''
      @current_scope.add_function name, signature.map { |parameter| parameter[:particle] }
      @current_scope = Scope.new @current_scope
      @indent_level += 1

      @tokens << Token.new(Token::FUNCTION_DEF, name)
      (@tokens << Token.new(Token::SCOPE_BEGIN)).last
    end

    def process_FUNCTION_CALL(chunk)
      name = chunk.gsub(/とは$/), ''
      function = @current_scope.get_function name

      signature = get_signature_from_stack

      function[:signature].each do |particle|
        begin
          parameter = signature.slice! signature.index { |p| p[:particle] == particle }
          @tokens << Token.new(Token::PARAMETER, parameter[:name])
        rescue
          error "Missing #{particle} parameter"
        end
      end

      (@tokens << Token.new(Token::FUNCTION_CALL, name)).last
    end

    def process_INLINE_COMMENT(chunk)
      (@tokens << Token.new(Token::INLINE_COMMENT, chunk)).last
    end

    def process_BLOCK_COMMENT(chunk)
      (@tokens << Token.new(Token::BLOCK_COMMENT, chunk)).last
    end

    def process_COMMENT(chunk)
      (@tokens << Token.new(Token::COMMENT, chunk)).last
    end

    def process_NO_OP(chunk)
      (@tokens << Token.new(Token::NO_OP, chunk)).last
    end

    def get_signature_from_stack
      signature = @stack.map do |token|
        parameter = token.content.match(/(.+)#{PARTICLE}$/)
        { name: parameter[0], particle: parameter[1] }
      end
      @stack.clear
      signature
    end
  end
end
