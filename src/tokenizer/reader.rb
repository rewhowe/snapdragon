require_relative 'errors.rb'
require_relative 'lexer.rb'

module Tokenizer
  class Reader
    attr_reader :line_num

    # Params:
    # +options+:: available options:
    #             * filename - input file to read from
    def initialize(options = {})
      @chunk         = ''
      @line_num      = 0
      @output_buffer = []

      @file = File.open options[:filename], 'r'
      ObjectSpace.define_finalizer(self, proc { @file.close unless @file.closed? })
    end

    def next_chunk(options = { consume?: true })
      read until finished? || !@output_buffer.empty?

      options[:consume?] ? @output_buffer.shift : @output_buffer.first
    end

    # Return the chunk if `skip_whitespace?` is false or the chunk is not whitespace
    # Otherwise, read until the first non-whitespace is found
    # (The buffer is searched on each iteration, but the actual number of elements will be at most <= 2)
    def peek_next_chunk(options = { skip_whitespace?: true })
      chunk = next_chunk consume?: false

      return chunk.to_s unless options[:skip_whitespace?] && chunk =~ /^[#{Lexer::WHITESPACE}]+$/

      read until !(chunk = non_whitespace_chunk_from_buffer).nil? || finished?

      chunk.to_s
    end

    def finished?
      @file.closed?
    end

    private

    # rubocop:disable Metrics/CyclomaticComplexity
    def read
      char = next_char

      case char
      when '「'
        store_chunk
        @chunk = char + read_until('」')
        return # continue reading in case the string is followed by a particle
      when '※'
        read_until '※' # discard until end of block comment
        return
      when "\n", /[#{Lexer::COMMA}#{Lexer::QUESTION}#{Lexer::BANG}]/
        store_chunk
        @chunk = char
      when /[#{Lexer::INLINE_COMMENT}]/
        read_until "\n", inclusive?: false
      when /[#{Lexer::WHITESPACE}]/
        store_chunk
        @chunk = char + read_until(/[^#{Lexer::WHITESPACE}]/, inclusive?: false)
      when nil
        finish
      else
        @chunk += char
        return
      end

      store_chunk
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def store_chunk
      return if @chunk.empty?
      @output_buffer << @chunk.clone
      @chunk.clear
    end

    def read_until(match, options = { inclusive?: true })
      char = nil
      chunk = ''

      loop do
        char = next_char.to_s

        # raise an error if match was never found before EOF
        raise_unfinished_range_error match if char.empty? && options[:inclusive?]

        chunk += char

        break if char.empty? || char_matches?(char, match, chunk)
      end

      return chunk if options[:inclusive?]

      restore_char char
      chunk.chomp char
    end

    def finish
      @file.close
    end

    def next_char
      char = @file.getc
      @line_num += 1 if char == "\n"
      char
    end

    def restore_char(char)
      @file.ungetc char
      @line_num -= 1 if char == "\n"
    end

    def char_matches?(char, match, chunk)
      return char =~ match if match.is_a? Regexp
      char == match && (match != '」' || chunk[-1] != '\\')
    end

    def non_whitespace_chunk_from_buffer
      @output_buffer.find { |chunk| chunk !~ /^[#{Lexer::WHITESPACE}]+$/ }
    end

    def raise_unfinished_range_error(match)
      case match
      when '」' then raise Errors::UnclosedString, @chunk
      when '※' then raise Errors::UnclosedBlockComment
      else raise Errors::UnexpectedEof
      end
    end
  end
end
