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

    # TODO: refactor in the future if possible
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
    def next_chunk(options = { consume?: true })
      while should_read? do
        char = @file.getc

        case char
        when '「'
          store_chunk
          @chunk = char
          read_until '」'
          next
        when '※'
          store_chunk
          read_until '※'
          @chunk.clear
        when "\n", /[#{Lexer::COMMA}#{Lexer::QUESTION}#{Lexer::BANG}]/
          store_chunk
          @chunk = char
          @line_num += 1
        when /[#{Lexer::INLINE_COMMENT}]/
          read_until "\n", inclusive?: false
          @chunk.clear
        when /[#{Lexer::WHITESPACE2}]/
          store_chunk
          @chunk += char
          read_until(/[^#{Lexer::WHITESPACE2}]/, inclusive?: false)
        when nil
          @file.close
        else
          @chunk += char
          next
        end

        store_chunk
      end

      options[:consume?] ? @output_buffer.shift : @output_buffer.first
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength

    def peek_next_chunk
      next_chunk consume?: false
    end

    private

    def should_read?
      !@file.closed? && @output_buffer.empty?
    end

    def store_chunk
      return if @chunk.empty?
      @output_buffer << @chunk.clone
      @chunk.clear
    end

    def read_until(match, options = { inclusive?: true })
      char = nil

      loop do
        char = @file.getc

        raise Errors::UnexpectedEof if char.nil?

        @chunk += char

        break if char == match || (match.is_a?(Regexp) && char =~ match)
      end

      return if options[:inclusive?]

      @chunk.chomp! char
      @file.ungetc char
    end
  end
end
