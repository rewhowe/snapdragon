require_relative '../string'
require_relative '../token'
require_relative '../util/i18n'
require_relative '../util/logger'
require_relative '../util/reserved_words'

require_relative 'oracles/property'
require_relative 'oracles/value'
require_relative 'built_ins'
require_relative 'conjugator'
require_relative 'constants'
require_relative 'context'
require_relative 'errors'
require_relative 'scope'

require_relative 'lexer/validators'
Dir["#{__dir__}/lexer/token_lexers/*.rb"].each { |f| require_relative f }

module Tokenizer
  class Lexer
    ############################################################################
    # TokenLexers consist of ONLY matching and tokenizing methods.
    #
    # Matching:
    # Short (~1 line) methods for identifying tokens.
    # These perform no validation and should simply determine if a chunk matches
    # an expected token given the chunk's contents, the surrounding tokens, and
    # successive chunks.
    #
    # Tokenizing:
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

    def initialize(reader, options = {})
      @reader  = reader
      @options = options

      @context       = Context.new
      @current_scope = Scope.new
      BuiltIns.inject_into @current_scope

      # The finalised token output. At any time, it may contain as many or as few tokens as required to complete a
      # sequence (as some tokens cannot be uniquely identified until subsequent tokens are parsed).
      @output_buffer = []
      # The chunks read in while parsing input. Each additional chunk is read while tokens are matched, but the
      # associated tokens (stored temporarily in the @stack) are not finalised until a terminal state is matched (EOL).
      # Upon mismatch, the current chunk index may be rolled back to match previous chunks with alternate terms.
      @chunks = ["\n"] # slight hack: begin with an EOL to process indent on first line
      @current_chunk_index = 0
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
      e.line_num = line_num + 1
      raise
    end

    def line_num
      @reader.line_num
    end

    def interpolate_string(interpolation)
      substitution = /【[#{WHITESPACE}]*(.+?)[#{WHITESPACE}]*】$/.match(interpolation)&.captures&.first

      raise Errors::EmptyOrUnclosedInterpolation, interpolation if substitution.nil?

      # split on possessive particle
      substitutes = substitution.split(/(^.+?)の[#{WHITESPACE}]+/)

      if substitutes.size == 1 # nothing split; just a variable
        substitute = substitutes.first
        sub_type = variable_type substitute, validate?: false
        interpolation_tokens = [Token.new(Token::RVALUE, substitute, sub_type: sub_type)]
      else
        property_owner, property = substitutes[1, 2] # drop leading empty

        owner_sub_type = variable_type property_owner, validate?: false
        property_owner_token = Token.new Token::POSSESSIVE, property_owner, sub_type: owner_sub_type

        # cannot validate because interpolation is done at runtime (scope is unknown)
        property_sub_type = property_type property, validate?: false
        property_token = Token.new Token::PROPERTY, Oracles::Property.sanitize(property), sub_type: property_sub_type

        interpolation_tokens = [property_owner_token, property_token]
      end

      validate_interpolation_tokens interpolation_tokens

      interpolation_tokens
    end

    # Reset the lexer state (for interactive mode).
    def reset
      @current_scope = @current_scope.parent until @current_scope.type == Scope::TYPE_MAIN
      function = @context.current_function_def
      @current_scope.remove_function function[:name], function[:signature] if function

      @output_buffer.clear
      @chunks.clear
      @current_chunk_index = 0
      @stack.clear

      @reader.reset
    end

    private

    def tokenize
      GRAMMAR.each do |name, sequence|
        Util::Logger.debug(Util::Options::DEBUG_1) { Util::I18n.t('tokenizer.try').pink + name }
        @output_buffer = []
        @stack = []
        begin
          return match_sequence sequence, 0, 0, 0
        rescue Errors::SequenceUnmatched => e
          Util::Logger.debug(Util::Options::DEBUG_1) { Util::I18n.t('tokenizer.sequence_unmatched').pink + e.message }
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
      @current_chunk_index = chunk_index # for peeking
      token_type = sequence[seq_index][:token]

      Util::Logger.debug(Util::Options::DEBUG_1) { " #{token_type}? ".yellow + "\"#{@chunks[chunk_index]}\"" }
      raise Errors::SequenceUnmatched, sequence[seq_index] unless send "#{token_type}?", @chunks[chunk_index]

      Util::Logger.debug(Util::Options::DEBUG_1) { Util::I18n.t('tokenizer.match').green + token_type.to_s }
      send "tokenize_#{token_type}", @chunks[chunk_index]

      if token_type == Token::EOL
        Util::Logger.debug(Util::Options::DEBUG_1) { Util::I18n.t('tokenizer.flush').green }
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
      Util::Logger.debug(Util::Options::DEBUG_1) { Util::I18n.t('tokenizer.read').yellow + "\"#{next_chunk}\"" }
      @chunks << next_chunk unless whitespace? next_chunk
    end

    # For peeking mid-sequence - when matching, successive chunks may have
    # already been consumed, so it's necessary to peek the current chunks before
    # peeking in the reader.
    def peek_next_chunk_in_seq
      @chunks[@current_chunk_index + 1] || @reader.peek_next_chunk
    end

    # Dangerous - permanently discards the next chunk mid-sequence. Presently
    # only used in tokenize_comma.
    def discard_next_chunk_in_seq!
      next_chunk = @chunks.slice! @current_chunk_index + 1, 1
      next_chunk&.first || @reader.next_chunk
    end

    # Obviously, it's necessary to dup the stack when saving its state,
    # otherwise changes to the stack will modify the saved state as well due to
    # Ruby's shallow copy.
    def save_state
      [@stack.dup, @context.last_token_type]
    end

    # Not-so-obviously, it's necessary to dup the stack AGAIN when restoring
    # state, otherwise subsequent changes to the stack will still modify the
    # saved state.
    def restore_state(state)
      @stack = state.first.dup
      @context.last_token_type = state.last
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
      Oracles::Value.special?(variable) || @current_scope.variable?(variable)
    end

    # Property Methods
    ############################################################################

    def property_type(property, options = { validate?: true })
      type = Oracles::Property.type property
      if options[:validate?] && type == Token::KEY_VAR && !variable?(property)
        raise Errors::PropertyDoesNotExist, property
      end
      type
    end

    # Common Matchers
    ############################################################################

    def whitespace?(chunk)
      chunk =~ /\A[#{WHITESPACE}]+\z/
    end

    # Technically should include bang? as well, but not necessary for now.
    def punctuation?(chunk)
      comma?(chunk) || question?(chunk)
    end

    # Helpers
    ############################################################################

    def process_indent
      next_chunk = @reader.peek_next_chunk skip_whitespace?: false
      return if (whitespace?(next_chunk) && eol?(@reader.peek_next_chunk)) || # next line is pure whitespace
                eol?(next_chunk)                                              # next line is empty

      indent_level = next_chunk.length - next_chunk.gsub(/\A[#{WHITESPACE}]+/, '').length

      raise Errors::UnexpectedIndent.new(@current_scope.level, indent_level) if indent_level > @current_scope.level

      unindent_to indent_level if indent_level < @current_scope.level
    end

    def unindent_to(indent_level)
      until @current_scope.level == indent_level do
        try_function_close if @current_scope.type == Scope::TYPE_FUNCTION_DEF

        @stack << Token.new(Token::SCOPE_CLOSE)

        is_alternate_branch = else_if?(@reader.peek_next_chunk) || else?(@reader.peek_next_chunk)
        # TODO: bugfix - cannot call else after function def inside if
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
      @context.current_function_def = nil if @current_scope.parent.type == Scope::TYPE_MAIN

      return if @context.last_token_type == Token::RETURN

      @stack += [
        Token.new(Token::PARAMETER, ID_NULL, particle: 'を', sub_type: Token::VAL_NULL),
        Token.new(Token::RETURN)
      ]
    end

    def try_assignment_close
      return unless Context.inside_assignment? @stack

      @stack << Token.new(Token::ARRAY_CLOSE) if Context.inside_array? @stack

      # add new variable to scope only if it is a new assignment (first token is not a possessive)
      assignment_token = @stack.first
      @current_scope.add_variable assignment_token.content if assignment_token.type == Token::ASSIGNMENT
    end

    # If the last segment does not contain a comparator, it must be an implicit
    # COMP_EQ check.
    def try_complete_implicit_eq_comparison
      comparator_token = last_segment_from_stack.first
      valid_comparator_tokens = [
        Token::COMP_LT,
        Token::COMP_LTEQ,
        Token::COMP_EQ,
        Token::COMP_NEQ,
        Token::COMP_GTEQ,
        Token::COMP_GT,
        Token::COMP_EMP,
        Token::COMP_NEMP,
        Token::COMP_IN,
        Token::COMP_NIN,
      ]
      return if valid_comparator_tokens.include? comparator_token.type

      # temporarily remove last segment
      stack = last_segment_from_stack!

      comparison_tokens = [Token.new(Token::COMP_EQ)]
      if stack.find { |t| t.type == Token::FUNCTION_CALL }
        stack.reject! { |t| t.type == Token::QUESTION }
      else # truthy check
        comparison_tokens << Token.new(Token::RVALUE, ID_TRUE, sub_type: Token::VAL_TRUE)
      end

      stack.unshift(*comparison_tokens)
      @stack += stack
    end

    def close_if_statement(comparison_tokens = [])
      @stack.insert last_condition_index_from_stack, *comparison_tokens unless comparison_tokens.empty?

      @context.inside_if_block = true

      begin_scope Scope::TYPE_IF_BLOCK

      Token.new Token::COMP_2 # for flavour
    end

    # Unlike the other *_from_stack methods, this is non-destructive.
    # Builds a parameter signature from the stack. For function retrieval, only
    # the particles are required, however the names are required for function
    # definitions.
    def signature_from_stack
      last_segment_from_stack.select { |t| t.type == Token::PARAMETER } .map do |token|
        { name: token.content, particle: token.particle }
      end
    end

    # Removes the last segment of the stack containing the function call parameters.
    # Loops over the defined signature to extract the parameters in that order.
    # Supplements an implicit それ parameter if required.
    # Re-adds the parameters to the stack.
    def regularize_function_call_parameters!(function)
      parameter_tokens = []

      # temporarily remove last segment
      stack = last_segment_from_stack!

      function[:signature].each do |signature_parameter|
        index = stack.index { |t| t.type == Token::PARAMETER && t.particle == signature_parameter[:particle] }
        parameter_token = stack.slice! index
        property_owner_token = slice_property_owner_token! stack, index

        validate_parameter parameter_token, property_owner_token

        parameter_tokens += [property_owner_token, parameter_token].compact
      end

      parameter_tokens.unshift implicit_parameter function if needs_implicit_parameter? function, parameter_tokens

      # re-add segment and parameter tokens
      @stack += stack + parameter_tokens
    end

    def needs_implicit_parameter?(function, parameter_tokens)
      parameter_tokens.count(&:particle) == 1 && function[:built_in?] && BuiltIns.math?(function[:name])
    end

    def implicit_parameter(function)
      implicit_particle = BuiltIns.implicit_math_particle function[:name]
      Token.new Token::PARAMETER, ID_SORE, particle: implicit_particle, sub_type: Token::VAR_SORE
    end

    def loop_parameter_from_stack!(particle)
      index = @stack.index { |t| t.particle == particle }

      return [nil, nil] unless index

      parameter_token = @stack.slice! index
      property_owner_token = slice_property_owner_token! @stack, index

      [parameter_token, property_owner_token]
    end

    # If inside an if statement: return the last conditional statement.
    # Otherwise: return the entire stack.
    def last_segment_from_stack
      last_condition_index = last_condition_index_from_stack
      last_condition_index.zero? ? @stack : @stack.slice(last_condition_index..-1)
    end

    # Destructive version of above
    def last_segment_from_stack!
      last_condition_index = last_condition_index_from_stack
      @stack.slice! last_condition_index..-1
    end

    # Returns the begining of the stack, or the index following IF, ELSE_IF, or
    # a conjunction (ie. the first index of the conditional tokens).
    def last_condition_index_from_stack
      index = @stack.rindex { |t| [Token::IF, Token::ELSE_IF, Token::AND, Token::OR].include? t.type }
      index.nil? ? 0 : index + 1
    end

    def slice_property_owner_token!(stack, index)
      stack.slice!(index - 1) if index.positive? && stack[index - 1].type == Token::POSSESSIVE
    end

    def comp_token(chunk)
      chunk = Oracles::Value.sanitize chunk

      if @context.last_token_type == Token::POSSESSIVE
        property_owner_token = @stack.last
        parameter_token = Token.new Token::PROPERTY, Oracles::Property.sanitize(chunk), sub_type: property_type(chunk)
        validate_property_and_owner parameter_token, property_owner_token
      else
        raise Errors::VariableDoesNotExist, chunk unless rvalue? chunk
        parameter_token = Token.new Token::RVALUE, chunk, sub_type: variable_type(chunk)
      end

      parameter_token
    end

    # Must return a mutable array (ie. this mapping cannot be constantized).
    def comp_2_comparison_tokens
      {
        # COMP_2, COMP_2_NOT, COMP_2_NOT_CONJ
        Token::QUESTION      => [Token.new(Token::COMP_EQ)],   # A？・関数呼び出す？
        Token::BANG          => [Token.new(Token::COMP_EQ)],   # 関数呼び出す！
        Token::FUNCTION_CALL => [Token.new(Token::COMP_EQ)],   # 関数呼び出す
        # Common
        Token::COMP_1        => [Token.new(Token::COMP_EQ)],   # Aが B
        Token::COMP_1_EQ     => [Token.new(Token::COMP_EQ)],   # Aが Bと 同じ
        Token::COMP_1_LTEQ   => [Token.new(Token::COMP_LTEQ)], # Aが B以下
        Token::COMP_1_GTEQ   => [Token.new(Token::COMP_GTEQ)], # Aが B以上
        Token::COMP_1_EMP    => [Token.new(Token::COMP_EMP)],  # Aが 空
      }[@context.last_token_type]
    end

    # This comparison comes in two patterns:
    # Aが あれば          - if A exists (truthy check)
    # Aが Bの 中に あれば - if A is inside B
    def comp_2_be_comparison_tokens!(chunk)
      case @context.last_token_type
      when Token::SUBJECT
        @stack << Token.new(Token::QUESTION)
        [
          Token.new(Token::COMP_EQ),
          Token.new(Token::RVALUE, ID_TRUE, sub_type: Token::VAL_TRUE),
        ]
      when Token::COMP_1_IN
        [Token.new(Token::COMP_IN)]
      else
        raise Errors::UnexpectedInput, chunk
      end
    end

    # Currently only flips COMP_EQ, COMP_LTEQ, COMP_GTEQ, COMP_EMP, COMP_IN in
    # one direction
    def flip_comparison(comparison_tokens)
      case comparison_tokens.first.type
      when Token::COMP_EQ   then comparison_tokens.first.type = Token::COMP_NEQ
      when Token::COMP_LTEQ then comparison_tokens.first.type = Token::COMP_GT
      when Token::COMP_GTEQ then comparison_tokens.first.type = Token::COMP_LT
      when Token::COMP_EMP  then comparison_tokens.first.type = Token::COMP_NEMP
      when Token::COMP_IN   then comparison_tokens.first.type = Token::COMP_NIN
      end
    end
  end
end
