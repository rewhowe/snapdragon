require_relative 'errors.rb'

module Tokenizer
  class Reader
    attr_reader :line_num

    def initialize(options = {})
      @options = options

      @chunk         = ''
      @line_num      = 1
      @output_buffer = []

      @file = File.open @options[:filename], 'r'
      ObjectSpace.define_finalizer(self, proc { @file.close unless @file.closed? })
    end

    def get_next_chunk(options = { consume?: true })
      read until @file.closed? || !@output_buffer.empty?

      options[:consume?] ? @output_buffer.shift : @output_buffer.first
    end

    # Return the chunk if `skip_whitespace?` is false or the chunk is not whitespace
    # Otherwise, read until the first non-whitespace is found
    # (The buffer is searched on each iteration, but the actual number of elements will be at most <= 2)
    def peek_next_chunk(options = { skip_whitespace?: true })
      chunk = get_next_chunk consume?: false

      return chunk.to_s unless options[:skip_whitespace?] && chunk =~ /^[#{Lexer::WHITESPACE}]+$/

      read until @file.closed? ||
                 !(chunk = @output_buffer.find { |buffered_chunk| buffered_chunk !~ /^[#{Lexer::WHITESPACE}]+$/ }).nil?

      @file.closed? ? '' : chunk
    end

    private

    # rubocop:disable Metrics/CyclomaticComplexity
    def read
      char = @file.getc

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
        @line_num += 1
      when /[#{Lexer::INLINE_COMMENT}]/
        read_until "\n", inclusive?: false
      when /[#{Lexer::WHITESPACE}]/
        store_chunk
        @chunk = char + read_until(/[^#{Lexer::WHITESPACE}]/, inclusive?: false)
      when nil
        @file.close
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
        char = @file.getc

        raise Errors::UnexpectedEof if char.nil?

        chunk += char

        break if char == match || (match.is_a?(Regexp) && char =~ match)
      end

      return chunk if options[:inclusive?]

      @file.ungetc char
      chunk.chomp char
    end
  end
end
