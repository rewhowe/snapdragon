require_relative '../errors'

module Tokenizer
  module Reader
    class BaseReader
      def initialize
        @chunk           = ''
        @line_num        = 0
        @output_buffer   = []
        @is_input_closed = false
      end

      def next_chunk(options = { consume?: true })
        read until finished? || !@output_buffer.empty?

        options[:consume?] ? @output_buffer.shift : @output_buffer.first
      end

      # Return the chunk if `skip_whitespace?` is false or the chunk is not
      # whitespace. Otherwise, read until the first non-whitespace is found
      # (The buffer is searched on each iteration, but the actual number of
      # elements will be at most <= 2)
      def peek_next_chunk(options = { skip_whitespace?: true })
        chunk = next_chunk consume?: false

        return chunk.to_s unless options[:skip_whitespace?] && chunk =~ /\A[#{WHITESPACE}]+\z/

        read until !(chunk = non_whitespace_chunk_from_buffer).nil? || @is_input_closed

        chunk.to_s
      end

      def finished?
        @is_input_closed && @output_buffer.empty?
      end

      def line_num
        @line_num - @output_buffer.count { |chunk| chunk == "\n" }
      end

      private

      def read
        char = next_char

        if char.nil?
          close_input
        else
          # rubocop:disable Style/CaseEquality
          reader_method = {
            '「'                           => :read_string_begin,
            '」'                           => :read_string_close,
            "\n"                           => :read_single_separator,
            /[#{COMMA}#{QUESTION}#{BANG}]/ => :read_single_separator,
            '※'                            => :read_inline_comment,
            /[#{COMMENT_BEGIN}]/           => :read_comment_begin,
            /[#{WHITESPACE}]/              => :read_whitespace,
            '\\'                           => :read_line_break,
          } .find { |match, method| break method if match === char } || :read_other
          # rubocop:enable Style/CaseEquality

          should_continue_reading = send reader_method, char
          return if should_continue_reading
        end

        store_chunk
      end

      # Continue reading in case the string is followed by a particle.
      def read_string_begin(char)
        store_chunk
        @chunk = char + read_until('」')
        true
      end

      def read_string_close(char)
        raise Errors::MalformedString, @chunk + char
      end

      def read_single_separator(char)
        store_chunk
        @chunk = char
        false
      end

      # Discard until EOL.
      def read_inline_comment(_char)
        read_until "\n", inclusive?: false
        false
      end

      # Discard until end of block.
      # Continue reading in case the block comment was in the middle of a chunk.
      def read_comment_begin(_char)
        read_until(/[#{COMMENT_CLOSE}]/)
        true
      end

      def read_whitespace(char)
        store_chunk
        @chunk = char + read_until(/[^#{WHITESPACE}]/, inclusive?: false)
        false
      end

      # Discard following whitespace, consume newline if found.
      def read_line_break(_char)
        store_chunk
        read_until(/[^#{WHITESPACE}]/, inclusive?: false)
        char = next_char
        raise Errors::UnexpectedLineBreak unless char == "\n"
        false
      end

      def read_other(char)
        @chunk += char
        true
      end

      def read_until(match, options = { inclusive?: true })
        char = nil
        chunk = ''

        loop do
          char = next_char_in_range match, chunk, options
          chunk += char

          # if reading a string and this is an unescaped start of interpolation:
          # read the entire substitution range
          chunk += read_until('】') if interpolation_open? match, chunk

          break if char.empty? || char_matches?(char, match, chunk)
        end

        return chunk if options[:inclusive?]

        restore_char char
        chunk.chomp char
      end

      def store_chunk
        return if @chunk.empty?
        @output_buffer << @chunk.clone
        @chunk.clear
      end

      def close_input
        @is_input_closed = true
      end

      def next_char
        char = read_char
        @line_num += 1 if char == "\n"
        char
      end

      def read_char
        raise
      end

      def restore_char(char)
        unread_char char
        @line_num -= 1 if char == "\n"
      end

      def unread_char
        raise
      end

      def next_char_in_range(match, chunk, options)
        char = next_char.to_s

        # raise an error if match was never found before EOF
        raise_unfinished_range_error match, chunk if char.empty? && options[:inclusive?]

        char
      end

      def interpolation_open?(match, chunk)
        match == '」' && chunk.match(/(\\*【)\z/)&.captures&.first&.length.to_i.odd?
      end

      def char_matches?(char, match, chunk)
        return char =~ match if match.is_a? Regexp
        char == match && (match != '」' || unescaped_closing_quote?(chunk))
      end

      def unescaped_closing_quote?(chunk)
        (chunk.match(/(\\*)」\z/)&.captures&.first&.length || 0).even?
      end

      def non_whitespace_chunk_from_buffer
        @output_buffer.find { |chunk| chunk !~ /\A[#{WHITESPACE}]+\z/ }
      end

      def raise_unfinished_range_error(match, chunk)
        raise Errors::UnclosedString, chunk if match == '」'
        raise Errors::UnclosedBlockComment if match == /[#{COMMENT_CLOSE}]/
        raise Errors::UnexpectedEof
      end
    end
  end
end
