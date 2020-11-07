require_relative '../colour_string'
require_relative '../token'
require_relative '../oracles/attribute'
require_relative '../oracles/value'
require_relative '../util/logger'
require_relative '../util/reserved_words'

require_relative 'built_ins'
require_relative 'conjugator'
require_relative 'constants'
require_relative 'context'
require_relative 'errors'
require_relative 'reader'
require_relative 'scope'

require_relative 'lexer/validators'
Dir["#{__dir__}/lexer/token_lexers/*.rb"].each { |f| require_relative f }

module Tokenizer
  class Lexer
    ############################################################################
    # TokenLexers consist of ONLY matching and processing methods.
    #
    # Matching:
    # Short (~1 line) methods for identifying tokens.
    # These perform no validation and should simply determine if a chunk matches
    # an expected token given the chunk's contents, the surrounding tokens, and
    # successive chunks.
    #
    # Processing:
    # These methods take chunks and parse their contents into particular tokens,
    # or sets of tokens, depending on the current context. Certain tokens are
    # only valid in certain situations, while others cannot be fully identified
    # until subsequent tokens have been processed.
    #
    # Any other common or helper methods will be in this file.
    ############################################################################
    include TokenLexers

    ############################################################################
    # Methods for determining the validity of chunks.
    # These methods should not mutate or return any value, simply throw an error
    # if the current state is considered invalid.
    ############################################################################
    include Validators

    def initialize(reader = Reader.new, options = {})
      @reader  = reader
      @options = options

      @context       = Context.new
      @current_scope = Scope.new
      BuiltIns.inject_into @current_scope

      # Start by processing any leading indentation on the first line.
      process_indent

      # The finalised token output. At any time, it may contain as many or as few tokens as required to complete a
      # sequence (as some tokens cannot be uniquely identified until subsequent tokens are parsed).
      @output_buffer = []
      # The chunks read in while parsing input. Each additional chunk is read while tokens are matched, but the
      # associated tokens (stored temporarily in the @stack) are not finalised until a terminal state is matched (EOL).
      # Upon mismatch, the current chunk index may be rolled back to match previous chunks with alternate terms.
      @chunks = []
      # The current stack of tokens which are part of a sequence.
      @stack = []
    end

    # If there are tokens in the buffer, return one immediately.
    # Otherwise, loop getting tokens until we have at least 1, or until the
    # Reader is finished.
    def next_token
      tokenize while !@reader.finished? && @output_buffer.empty?

      if @reader.finished? && @output_buffer.empty?
        unindent_to 0
        @output_buffer += @stack
      end

      @output_buffer.shift
    rescue Errors::BaseError => e
      e.line_num = line_num
      raise
    end

    def line_num
      @reader.line_num
    end

    private

    def tokenize
      GRAMMAR.each do |name, sequence|
        Util::Logger.debug Util::Options::DEBUG_1, 'TRY: '.pink + name
        @output_buffer = []
        @stack = []
        begin
          return match_sequence sequence, 0, 0, 0
        rescue Errors::SequenceUnmatched => e
          Util::Logger.debug Util::Options::DEBUG_1, 'SequenceUnmatched: '.pink + e.message
        end
      end

      raise Errors::UnexpectedInput, @chunks.last || @reader.peek_next_chunk(skip_whitespace?: false)
    end

    # Returns immediately if the current sequence index is greater than the
    # sequence size (ie. the sequence is finished).
    # Reads additional chunks if required.
    #
    # If the current term is a branching sequence:
    # * Match one possibility and follow the sequence
    # * If it fails: rollback, try a different possibility, and follow
    # * If all possibilities fail: raise an unmatched error
    #
    # If the current term is something else, simply follow the sequence.
    # Returns the index of the next chunk to be read.
    def match_sequence(sequence, seq_index, match_count, chunk_index)
      return chunk_index if seq_index >= sequence.size

      read_chunk while chunk_index >= @chunks.size

      state = save_state

      if sequence[seq_index][:branch_sequence]
        sequence[seq_index][:branch_sequence].each do |s|
          begin
            term_matcher = proc { match_sequence [s], 0, 0, chunk_index }
            return follow_sequence sequence, seq_index, match_count, chunk_index, term_matcher
          rescue Errors::SequenceUnmatched
            restore_state state
          end
        end

        raise Errors::SequenceUnmatched, sequence[seq_index]
      end

      term_matcher = proc { match_term sequence, seq_index, chunk_index }
      follow_sequence sequence, seq_index, match_count, chunk_index, term_matcher
    rescue Errors::SequenceUnmatched => e
      restore_state state
      raise e
    end

    # Attempts to match the current term with the given "term_matcher".
    # "term_matcher" either matches the current term, or matches a possible
    # branch sequence.
    # If the term matches and the match count is greater than the current term's
    # modifier, then match the next term with the next chunk.
    # Otherwise, increment the match count and match the current term again with
    # the next chunk.
    # Returns the index of the next chunk to be read.
    def follow_sequence(sequence, seq_index, match_count, chunk_index, term_matcher)
      state = save_state
      begin
        # match the current term with the current chunk
        next_chunk_index = term_matcher.call

        if (match_count + 1) >= sequence[seq_index][:mod].last
          # if the current term has been matched enough times: match the next term with the next chunk
          match_sequence sequence, seq_index + 1, 0, next_chunk_index
        else
          # the current term may accept or requires additional matches: match this term again with the next chunk
          match_sequence sequence, seq_index, match_count + 1, next_chunk_index
        end
      rescue Errors::SequenceUnmatched => e
        restore_state state

        # raise an unmatched error unless the current matched count is acceptable
        raise e unless sequence[seq_index][:mod].include? match_count

        # didn't work; match the next term with the current chunk
        return match_sequence sequence, seq_index + 1, 0, chunk_index
      end
    end

    # If the term is:
    # 1. A single token    -> match and process
    # 2. A sub sequence    -> try matching the sequence
    # 3. A branch sequence -> try matching the sequence
    # Returns the index of the next chunk to be read.
    def match_term(sequence, seq_index, chunk_index)
      if sequence[seq_index][:token]
        chunk_index = match_token sequence, seq_index, chunk_index

      elsif sequence[seq_index][:sub_sequence]
        chunk_index = match_sequence sequence[seq_index][:sub_sequence], 0, 0, chunk_index

      elsif sequence[seq_index][:branch_sequence]
        chunk_index = match_sequence sequence[seq_index][:branch_sequence], 0, 0, chunk_index
      end

      chunk_index
    end

    # Raise an error unless the chunk matches the token.
    # Otherwise processes the token.
    # Flushes the stack to the output buffer if the token is an EOL.
    # Returns the index of the next chunk to be read.
    def match_token(sequence, seq_index, chunk_index)
      token_type = sequence[seq_index][:token]

      Util::Logger.debug Util::Options::DEBUG_1, " #{token_type}? ".yellow + "\"#{@chunks[chunk_index]}\""
      raise Errors::SequenceUnmatched, sequence[seq_index] unless send "#{token_type}?", @chunks[chunk_index]

      Util::Logger.debug Util::Options::DEBUG_1, 'MATCH: '.green + token_type.to_s
      send "process_#{token_type}", @chunks[chunk_index]

      if token_type == Token::EOL
        Util::Logger.debug Util::Options::DEBUG_1, 'FLUSH'.green
        @output_buffer += @stack
        @chunks.clear
        @stack.clear
      end

      @context.last_token_type = token_type

      chunk_index + 1
    end

    # Reads the chunk (but discards it if it is whitespace).
    def read_chunk
      next_chunk = @reader.next_chunk
      raise Errors::UnexpectedEof if next_chunk.nil?
      Util::Logger.debug Util::Options::DEBUG_1, 'READ: '.yellow + "\"#{next_chunk}\""
      @chunks << next_chunk unless whitespace? next_chunk
    end

    def save_state
      [@stack.dup, @context.last_token_type]
    end

    def restore_state(state)
      @stack, @context.last_token_type = state
    end

    # Variable Methods
    ############################################################################

    def variable_type(value, options = { validate?: true })
      Oracles::Value.type(value) || begin
        raise Errors::VariableDoesNotExist, value if options[:validate?] && !variable?(value)
        Token::VARIABLE
      end
    end

    def variable?(variable)
      variable =~ /^(それ|あれ)$/ || @current_scope.variable?(variable)
    end

    def sanitize_variable(value)
      # Strips leading and trailing whitespace and newlines within the string.
      # Whitespace at the beginning and ending of the string are not stripped.
      if Oracles::Value.string? value
        value = value.gsub(/[#{WHITESPACE}]*\n[#{WHITESPACE}]*/, '')
        value = value.gsub(/\\\\/, '\\')
        value.gsub(/((?<!\\)\\n|(?<!￥)￥ｎ)/, "\n")
      elsif Oracles::Value.number? value
        value.tr 'ー．０-９', '-.0-9'
      else
        value
      end
    end

    # Attribute Methods
    ############################################################################

    def attribute_type(attribute, options = { validate?: true })
      type = Oracles::Attribute.type attribute
      if options[:validate?] && type == Token::KEY_VAR && !variable?(attribute)
        raise Errors::AttributeDoesNotExist, attribute
      end
      type
    end

    # Common Matchers
    ############################################################################

    def whitespace?(chunk)
      chunk =~ /^[#{WHITESPACE}]+$/
    end

    # Technically should include bang? as well, but not necessary for now.
    def punctuation?(chunk)
      comma?(chunk) || question?(chunk)
    end

    # Common Processors
    ############################################################################

    def process_indent
      next_chunk = @reader.peek_next_chunk skip_whitespace?: false
      return if (whitespace?(next_chunk) && eol?(@reader.peek_next_chunk)) || # next line is pure whitespace
                eol?(next_chunk)                                              # next line is empty

      indent_level = next_chunk.length - next_chunk.gsub(/\A[#{WHITESPACE}]+/, '').length

      raise Errors::UnexpectedIndent if indent_level > @current_scope.level

      unindent_to indent_level if indent_level < @current_scope.level
    end

    # Helpers
    ############################################################################

    def unindent_to(indent_level)
      until @current_scope.level == indent_level do
        try_function_close if @current_scope.type == Scope::TYPE_FUNCTION_DEF

        @stack << Token.new(Token::SCOPE_CLOSE)

        is_alternate_branch = else_if?(@reader.peek_next_chunk) || else?(@reader.peek_next_chunk)
        @context.inside_if_block = false if @context.inside_if_block? && !is_alternate_branch

        @current_scope = @current_scope.parent
      end
    end

    def begin_scope(type)
      @current_scope = Scope.new @current_scope, type
      @stack << Token.new(Token::SCOPE_BEGIN)
    end

    # If the last token of a function is not a return, return null.
    def try_function_close
      return if @context.last_token_type == Token::RETURN

      @stack += [
        Token.new(Token::PARAMETER, '無', particle: 'を', sub_type: Token::VAL_NULL),
        Token.new(Token::RETURN)
      ]
    end

    def try_assignment_close
      return unless Context.inside_assignment? @stack

      @stack << Token.new(Token::ARRAY_CLOSE) if Context.inside_array? @stack

      # TODO: (v1.1.0) or 1st token is PROPERTY and 2nd is ASSIGNMENT
      assignment_token = @stack.first
      unless assignment_token.type == Token::ASSIGNMENT
        raise Errors::UnexpectedInput, assignment_token.content || assignment_token.to_s.upcase
      end

      @current_scope.add_variable assignment_token.content
    end

    def close_if_statement(comparison_tokens = [])
      @stack.insert 1, *comparison_tokens unless comparison_tokens.empty?

      @context.inside_if_block = true

      begin_scope Scope::TYPE_IF_BLOCK

      Token.new Token::COMP_3
    end

    # Unlike the other *_from_stack methods, this is non-destructive.
    # Builds a parameter signature from the stack. For function retrieval, only
    # the particles are required, however the names are required for function
    # definitions.
    def signature_from_stack
      @stack.select { |t| t.type == Token::PARAMETER } .map do |token|
        { name: token.content, particle: token.particle }
      end
    end

    def function_call_parameters_from_stack!(function)
      parameter_tokens = []

      function[:signature].each do |signature_parameter|
        index = @stack.index { |t| t.type == Token::PARAMETER && t.particle == signature_parameter[:particle] }
        parameter_token = @stack.slice! index

        property_token = property_token_from_stack! index
        validate_parameter parameter_token, property_token

        parameter_tokens += [property_token, parameter_token].compact
      end

      num_parameters = parameter_tokens.count(&:particle)
      if num_parameters == 1 && function[:built_in?] && BuiltIns.math?(function[:name])
        implicit_particle = BuiltIns.implicit_math_particle function[:name]
        implicit_token = Token.new Token::PARAMETER, 'それ', particle: implicit_particle, sub_type: Token::VAR_SORE
        parameter_tokens.unshift implicit_token
      end

      parameter_tokens
    end

    def loop_parameter_from_stack!(particle)
      index = @stack.index { |t| t.particle == particle }

      return [nil, nil] unless index

      parameter_token = @stack.slice! index
      property_token = property_token_from_stack! index

      [parameter_token, property_token]
    end

    def property_token_from_stack!(index)
      @stack.slice!(index - 1) if index.positive? && @stack[index - 1].type == Token::PROPERTY
    end

    def comp_token(chunk)
      chunk = sanitize_variable chunk

      if @context.last_token_type == Token::PROPERTY
        property_token = @stack.last
        parameter_token = Token.new Token::ATTRIBUTE, chunk, sub_type: attribute_type(chunk)
        validate_property_and_attribute property_token, parameter_token
      else
        raise Errors::VariableDoesNotExist, chunk unless rvalue? chunk
        parameter_token = Token.new Token::RVALUE, chunk, sub_type: variable_type(chunk)
      end

      parameter_token
    end

    # rubocop:disable Layout/MultilineOperationIndentation
    def stack_is_truthy_check?
      (@stack.size == 2 && @stack[1].type == Token::RVALUE)   || # stack is just IF/ELSE_IF and COMP_2
      (@stack.size == 3 && @stack[1].type == Token::PROPERTY) || # stack is just IF/ELSE_IF and a PROPERTY/ATTRIBUTE
      (@stack.find { |t| t.type == Token::FUNCTION_CALL })    || # stack is a function call result
      false
    end
    # rubocop:enable Layout/MultilineOperationIndentation

    # Currently only flips COMP_EQ, COMP_LTEQ, COMP_GTEQ
    def flip_comparison(comparison_tokens)
      case comparison_tokens.first.type
      when Token::COMP_EQ   then comparison_tokens.first.type = Token::COMP_NEQ
      when Token::COMP_LTEQ then comparison_tokens.first.type = Token::COMP_GT
      when Token::COMP_GTEQ then comparison_tokens.first.type = Token::COMP_LT
      end
    end
  end
end
