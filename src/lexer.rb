require File.join(File.dirname(__FILE__), 'scope.rb')
require File.join(File.dirname(__FILE__), 'token.rb')
require File.join(File.dirname(__FILE__), 'conjugator.rb')
require File.join(File.dirname(__FILE__), 'colour_string.rb')

class Lexer
  PARTICLE   = '(?:から|と|に|へ|まで|で|を)'.freeze # 使用可能助詞
  COUNTER    = %w(つ 人 個 匹 子 頭).freeze          # 使用可能助数詞
  WHITESPACE = '[\s　]'.freeze                       # 空白文字
  COMMA      = '[,、]'.freeze                        # カンマ
  QUESTION   = '[?？]'.freeze
  BANG       = '[!！]'.freeze

  TOKEN_NFSM = {
    Token::BOL => [
      Token::EOL,
      Token::COMMENT,
      Token::BLOCK_COMMENT,
      Token::FUNCTION_CALL,
      Token::FUNCTION_DEF,
      Token::INLINE_COMMENT, # TODO: allow these after other tokens as well
      Token::NO_OP,
      Token::VARIABLE_H,
      Token::VARIABLE_P,
    ],
    Token::VARIABLE_H => [
      Token::VARIABLE,
    ],
    Token::VARIABLE => [
      Token::EOL,
      Token::AND,
      Token::QUESTION,
      Token::COMMA,
    ],
    Token::VARIABLE_P => [
      Token::VARIABLE_P,
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
    Token::AND => [
      Token::VARIABLE,
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
  }

  def initialize(options)
    @options = options
    puts @options if @options[:debug]

    @tokens = [Token::BOL]
    @indent_level = 0
    @current_scope = Scope.new
    @is_inside_block_comment = false
  end

  class << self

    def tokenize(filename)
      puts filename if @options[:debug]

      File.foreach(filename).with_index(1) do |line, line_num|
        begin
          @line = line.gsub(/#{WHITESPACE}*$/, '')
          puts 'READ: ' + @line if @options[:debug]

          next if @line.empty?

          process_indent

          until @line.empty? do
            chunk = get_next_chunk

            token = nil
            TOKEN_NFSM[@tokens.last].each do |next_token|
              if send "is_#{next_token}?", chunk
                token = send "process_#{next_token}", chunk
                break
              end
            end

            if token
              @tokens << token
            else
              error "Unexpected input on line #{line_num}" if token.nil?
            end
          end

          unless TOKEN_NFSM[@tokens.last].include? Token::EOL
            error "Unexpected EOL on line #{line_num}"
          end

        rescue => e
          raise e unless @options[:debug]
          puts "An error occured while tokenizing on line #{line_num}"
          puts e.message
        end
      end
    end

    private

    def error(message, level)
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
      return unless match_data = @line.match(/^#{WHITESPACE}+/)

      indent_level = match_data.captures.first.count '　'
      indent_level += match_data.captures.first.count ' '

      if indent_level > @expected_indent
        error 'Unexpected indent', :critical
      elsif indent_level < @expected_indent
        @tokens << Token::CLOSE_SCOPE
        @expected_indent = indent_level
      end

      @line.gsub!(/^#{WHITESPACE}+/, '')
    end

    def get_next_chunk(should_consume=true)
      split_line = @line.split(/(#{WHITESPACE}|#{QUESTION}|#{BANG}|#{COMMA})/)

      chunk = nil
      until split_line.empty?
        chunk = split_line.shift.gsub(/#{WHITESPACE}"/, '')
        break unless chunk.empty?
      end

      @line = split_line.join if should_consume

      chunk.to_s.empty? ? nil : chunk
    end

    def peek_next_chunk
      get_next_chunk false
    end

    def is_EOL(chunk)
      false
    end

    def is_QUESTION(chunk)
      chunk =~ /^#{QUESTION}$/
    end

    def is_BANG(chunk)
      chunk =~ /^#{BANG}$/
    end

    def is_COMMA(chunk)
      chunk =~ /^#{COMMA}$/
    end

    def is_VARIABLE(chunk)
      is_value?(chunk) || @current_scope.has_variable?(chunk)
    end

    def is_VARIABLE_H(chunk)
      chunk =~ /^.+は$/
    end

    def is_VARIABLE_P(chunk)
      chunk =~ /^.+#{PARTICLE}$/ && !peek_next_chunk.nil?
    end

    def is_FUNCTION_DEF(chunk)
      chunk =~ /^.+とは$/ && peek_next_chunk.nil?
    end

    def is_FUNCTION_CALL(chunk)
      return true if @tokens.last.type === Token::VARIABLE_P && !is_VARIABLE_P(chunk)
      return true if @tokens.last.type === Token::BOL && @current_scope.has_function?(chunk)
      false
    end

    def is_INLINE_COMMENT(chunk)
      chunk =~ /^(\(|（).*$/
    end

    def is_BLOCK_COMMENT(chunk)
      chunk =~ /^※.*$/
    end

    def is_COMMENT(chunk)
      @is_inside_block_comment
    end

    def is_AND(chunk)
      chunk == 'と'
    end

    def is_NO_OP(chunk)
      chunk == '・・・'
    end
  end
end
