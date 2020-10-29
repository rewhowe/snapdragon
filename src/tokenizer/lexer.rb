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

      # The finalised token output. At any time, it may contain as many or as few tokens as required to complete a
      # sequence (as some tokens cannot be uniquely identified until subsequent tokens are parsed).
      # @tokens = []
      # The last token parsed in the sequence. It may not be present in @tokens, but is guaranteed to represent the last
      # token parsed.
      # TODO: maybe replace wit @tokens.last&.type || Token::EOL
      @last_token_type = Token::EOL
      # The current stack of tokens which are part of a sequence.
      @stack = []

      # NEW
      @chunks = []
      @output_buffer = []
    end

    EXACTLY_ONE  = (1..1)
    ZERO_OR_ONE  = (0..1)
    ZERO_OR_MORE = (0..Float::INFINITY)
    ONE_OR_MORE  = (1..Float::INFINITY)

    # The grammar consists of mutiple possible valid sequences.
    # Each sequence is made up of terms.
    #
    # A term represents one of:
    # 1. A token           - the next valid token in the sequence
    # 2. A branch sequence - a list of possible valid terms (an "OR" group)
    # 3. A sub sequence    - a list of successive valid terms (an "AND" group)
    GRAMMAR = {
      'Empty Line' => [ { mod: EXACTLY_ONE, token: Token::EOL } ],

      'Assignment' => [
        { mod: EXACTLY_ONE, token: Token::ASSIGNMENT },      # ASSIGNMENT
        { mod: EXACTLY_ONE, branch_sequence: [               # (
          { mod: EXACTLY_ONE, token: Token::RVALUE },        #   RVALUE
          { mod: EXACTLY_ONE, sub_sequence: [                #   | (
            { mod: EXACTLY_ONE, token: Token::PROPERTY },    #     PROPERTY
            { mod: EXACTLY_ONE, token: Token::ATTRIBUTE },   #     ATTRIBUTE
          ] },                                               #   )
        ], },                                                # )
        { mod: ZERO_OR_ONE, token: Token::QUESTION, },       # QUESTION ?
        { mod: ZERO_OR_MORE, sub_sequence: [                 # (
          { mod: EXACTLY_ONE, token: Token::COMMA },         #   COMMA
          { mod: EXACTLY_ONE, branch_sequence: [             #   (
            { mod: EXACTLY_ONE, token: Token::RVALUE },      #     RVALUE
            { mod: EXACTLY_ONE, sub_sequence: [              #     | (
              { mod: EXACTLY_ONE, token: Token::PROPERTY },  #       PROPERTY
              { mod: EXACTLY_ONE, token: Token::ATTRIBUTE }, #       ATTRIBUTE
            ] },                                             #     )
          ] },                                               #   )
          { mod: ZERO_OR_ONE, token: Token::QUESTION, },     #   QUESTION ?
        ] },                                                 # ) *
        { mod: EXACTLY_ONE, token: Token::EOL },             # EOL
      ],

      'Function Def' => [
        { mod: ZERO_OR_MORE, token: Token::PARAMETER },   # PARAMETER *
        { mod: EXACTLY_ONE, token: Token::FUNCTION_DEF }, # FUNCTION_DEF
        { mod: ZERO_OR_ONE, token: Token::BANG },         # BANG ?
        { mod: EXACTLY_ONE, token: Token::EOL },          # EOL
      ],

      'Function Call' => [
        { mod: ZERO_OR_MORE, sub_sequence: [               # (
          { mod: ZERO_OR_ONE, token: Token::PROPERTY },    #  PROPERTY ?
          { mod: EXACTLY_ONE, token: Token::PARAMETER },   #  PARAMETER
        ] },                                               # ) *
        { mod: EXACTLY_ONE, token: Token::FUNCTION_CALL }, # FUNCTION_CALL
        { mod: ZERO_OR_ONE, token: Token::BANG },          # BANG ?
        { mod: ZERO_OR_ONE, token: Token::QUESTION },      # QUESTION ?
        { mod: EXACTLY_ONE, token: Token::EOL },           # EOL
      ],

      'Return' => [
        { mod: ZERO_OR_ONE, sub_sequence: [              # (
          { mod: ZERO_OR_ONE, token: Token::PROPERTY },  #   PROPERTY ?
          { mod: EXACTLY_ONE, token: Token::PARAMETER }, #   PARAMETER
        ] },                                             # ) ?
        { mod: EXACTLY_ONE, token: Token::RETURN },      # RETURN
        { mod: EXACTLY_ONE, token: Token::EOL },         # EOL
      ],

      'Loop' => [
        { mod: ZERO_OR_ONE, sub_sequence: [                    # (
          { mod: ZERO_OR_ONE, token: Token::PROPERTY },        #   PROPERTY ?
          { mod: EXACTLY_ONE, token: Token::PARAMETER },       #   PARAMETER
          { mod: EXACTLY_ONE, branch_sequence: [               #   (
            { mod: EXACTLY_ONE, sub_sequence: [                #     (
              { mod: ZERO_OR_ONE, token: Token::PROPERTY },    #       PROPERTY ?
              { mod: EXACTLY_ONE, token: Token::PARAMETER },   #       PARAMETER
            ] },                                               #     )
            { mod: EXACTLY_ONE, token: Token::LOOP_ITERATOR }, #     | LOOP_ITERATOR
          ] },                                                 #   )
        ] },                                                   # ) ?
        { mod: EXACTLY_ONE, token: Token::LOOP },              # LOOP
        { mod: EXACTLY_ONE, token: Token::EOL },               # EOL
      ],

      'If Comparison' => [
        { mod: EXACTLY_ONE, branch_sequence: [                 # (
          { mod: EXACTLY_ONE, token: Token::IF },              #   IF
          { mod: EXACTLY_ONE, token: Token::ELSE_IF },         #   | ELSE_IF
        ] },                                                   # )
        { mod: ZERO_OR_ONE, sub_sequence: [                    # (
          { mod: ZERO_OR_ONE, token: Token::PROPERTY },        #   PROPERTY ?
          { mod: EXACTLY_ONE, token: Token::COMP_1 },          #   COMP_1
        ] },                                                   # ) ?
        { mod: ZERO_OR_ONE, token: Token::PROPERTY },          # PROPERTY ?
        { mod: EXACTLY_ONE, branch_sequence: [                 # (
          { mod: EXACTLY_ONE, sub_sequence: [                  #   (
            { mod: EXACTLY_ONE, branch_sequence: [             #     (
              { mod: EXACTLY_ONE, sub_sequence: [              #       (
                { mod: EXACTLY_ONE, token: Token::COMP_2 },    #         COMP_2
                { mod: EXACTLY_ONE, token: Token::QUESTION },  #         QUESTION
              ] },                                             #       )
              { mod: EXACTLY_ONE, token: Token::COMP_2_GTEQ }, #       | COMP_2_GTEQ
              { mod: EXACTLY_ONE, token: Token::COMP_2_LTEQ }, #       | COMP_2_LTEQ
            ] },                                               #     )
            { mod: EXACTLY_ONE, branch_sequence: [             #     (
              { mod: EXACTLY_ONE, token: Token::COMP_3 },      #       COMP_3
              { mod: EXACTLY_ONE, token: Token::COMP_3_NOT },  #       | COMP_3
            ] },                                               #     )
          ] },                                                 #   )
          { mod: EXACTLY_ONE, sub_sequence: [                  #   | (
            { mod: EXACTLY_ONE, token: Token::COMP_2_TO },     #     COMP_2_TO
            { mod: EXACTLY_ONE, branch_sequence: [             #     (
              { mod: EXACTLY_ONE, token: Token::COMP_3_EQ },   #       COMP_3_EQ
              { mod: EXACTLY_ONE, token: Token::COMP_3_NEQ },  #       | COMP_3_NEQ
            ] },                                               #     )
          ] },                                                 #   )
          { mod: EXACTLY_ONE, sub_sequence: [                  #   | (
            { mod: EXACTLY_ONE, token: Token::COMP_2_YORI },   #     COMP_2_YORI
            { mod: EXACTLY_ONE, branch_sequence: [             #     (
              { mod: EXACTLY_ONE, token: Token::COMP_3_LT },   #       COMP_3_YORI
              { mod: EXACTLY_ONE, token: Token::COMP_3_GT },   #       | COMP_3_GT
            ] },                                               #     )
          ] },                                                 #   )
        ] },                                                   # )
        { mod: EXACTLY_ONE, token: Token::EOL },               # EOL
      ],

      'If Function Call' => [
        { mod: EXACTLY_ONE, branch_sequence: [             # (
          { mod: EXACTLY_ONE, token: Token::IF },          #   IF
          { mod: EXACTLY_ONE, token: Token::ELSE_IF },     #   | ELSE_IF
        ] },                                               # )
        { mod: ZERO_OR_MORE, sub_sequence: [               # (
          { mod: ZERO_OR_ONE, token: Token::PROPERTY },    #  PROPERTY ?
          { mod: EXACTLY_ONE, token: Token::PARAMETER },   #  PARAMETER
        ] },                                               # ) *
        { mod: EXACTLY_ONE, token: Token::FUNCTION_CALL }, # FUNCTION_CALL
        { mod: ZERO_OR_ONE, token: Token::BANG },          # BANG ?
        { mod: ZERO_OR_ONE, token: Token::QUESTION },      # QUESTION ?
        { mod: EXACTLY_ONE, branch_sequence: [             # (
          { mod: EXACTLY_ONE, token: Token::COMP_3 },      #   COMP_3
          { mod: EXACTLY_ONE, token: Token::COMP_3_NOT },  #   | COMP_3
        ] },                                               # )
        { mod: EXACTLY_ONE, token: Token::EOL },           # EOL
      ],

      'Else' => [ { mod: EXACTLY_ONE, token: Token::ELSE }, { mod: EXACTLY_ONE, token: Token::EOL } ],

      'Next' => [ { mod: EXACTLY_ONE, token: Token::NEXT }, { mod: EXACTLY_ONE, token: Token::EOL } ],

      'Break' => [ { mod: EXACTLY_ONE, token: Token::BREAK }, { mod: EXACTLY_ONE, token: Token::EOL } ],

      'No Op' => [ { mod: EXACTLY_ONE, token: Token::NO_OP }, { mod: EXACTLY_ONE, token: Token::EOL } ],
    }.freeze

    # If there are tokens in the buffer, return one immediately.
    # Otherwise, loop getting tokens until we have at least 1, or until the
    # Reader is finished.
    def next_token
      tokenize while !@reader.finished? && @output_buffer.empty?

      if @reader.finished? && @output_buffer.empty?
        unindent_to 0
        @output_buffer += @stack
        # validate_sequence_finish
      end

      @output_buffer.shift
    rescue Errors::BaseError => e
      e.line_num = @reader.line_num
      raise
    end

    private

    def tokenize
      GRAMMAR.each do |name, sequence|
        Util::Logger.debug 'TRY: '.pink + name
        @output_buffer = []
        @stack = []
        begin
          match_sequence sequence, 0, 0, 0
          raise Errors::UnexpectedEof, @chunks.last unless @chunks.empty? # TODO: different error
          return true
        rescue Errors::SequenceUnmatched => e
          Util::Logger.debug 'SequenceUnmatched: '.pink + e.message
        end
      end

      # TODO: (v1.1.0) Idea: catch BaseError above and re-raise below if present
      trailing_characters = @reader.peek_next_chunk skip_whitespace?: false
      raise Errors::UnexpectedInput, @chunks.last + (whitespace?(trailing_characters) ? '' : trailing_characters)
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
    # If the current term is something else, simply follow the sequence
    def match_sequence(sequence, s_i, s_count, t_i)
      return t_i if s_i >= sequence.size

      read_chunk while t_i >= @chunks.size

      stack_state = @stack.dup

      if sequence[s_i][:branch_sequence]
        sequence[s_i][:branch_sequence].each do |s|
          begin
            term_matcher = proc { match_sequence [s], 0, 0, t_i }
            return follow_sequence sequence, s_i, s_count, t_i, term_matcher
          rescue Errors::SequenceUnmatched
            @stack = stack_state
          end
        end

        raise Errors::SequenceUnmatched, sequence[s_i]
      end

      term_matcher = proc { match_term sequence, s_i, t_i }
      follow_sequence sequence, s_i, s_count, t_i, term_matcher
    rescue Errors::SequenceUnmatched => e
      @stack = stack_state
      raise e
    end

    # Attempts to match the current term with the given "term_matcher".
    # "term_matcher" either matches the current term, or matches a possible
    # branch sequence.
    # If the term matches and the match count is greater than the current term's
    # modifier, then match the next term with the next chunk.
    # Otherwise, increment the match count and match the current term again with
    # the next chunk.
    def follow_sequence(sequence, s_i, s_count, t_i, term_matcher)
      stack_state = @stack.dup
      begin
        # match the current term with the current chunk
        next_t_i = term_matcher.call

        # if the current term has been matched enough times: match the next term with the next chunk
        return match_sequence sequence, s_i + 1, 0, next_t_i if (s_count + 1) >= sequence[s_i][:mod].last

        # the current term may accept or requires additional matches: match this term again with the next chunk
        return match_sequence sequence, s_i, s_count + 1, next_t_i
      rescue Errors::SequenceUnmatched => e
        @stack = stack_state

        # raise an unmatched error unless the current matched count is acceptable
        raise e unless sequence[s_i][:mod].include? s_count

        # didn't work; match the next term with the current chunk
        return match_sequence sequence, s_i + 1, 0, t_i
      end
    end

    # If the term is:
    # 1. A single token    -> match and process
    # 2. A sub sequence    -> try matching the sequence
    # 3. A branch sequence -> try matching the sequence
    def match_term(sequence, s_i, t_i)
      if sequence[s_i][:token]
        t_i = match_token sequence, s_i, t_i

      elsif sequence[s_i][:sub_sequence]
        t_i = match_sequence sequence[s_i][:sub_sequence], 0, 0, t_i

      elsif sequence[s_i][:branch_sequence]
        match_sequence sequence[s_i][:branch_sequence], 0, 0, t_i
      end

      t_i
    end

    # Raise an error unless the chunk matches the token.
    # Otherwise processes the token.
    # Flushes the stack to the output buffer if the token is an EOL.
    def match_token(sequence, s_i, t_i)
      token_type = sequence[s_i][:token]

      Util::Logger.debug " #{token_type}? ".yellow + "\"#{@chunks[t_i]}\""
      raise Errors::SequenceUnmatched, sequence[s_i] unless send "#{token_type}?", @chunks[t_i]

      Util::Logger.debug 'MATCH: '.green + token_type.to_s
      send "process_#{token_type}", @chunks[t_i]

      if token_type == Token::EOL
        Util::Logger.debug 'FLUSH'.green
        @output_buffer += @stack
        @chunks.clear
        @stack.clear
      end

      @last_token_type = token_type

      t_i + 1
    end

    def read_chunk
      next_chunk = @reader.next_chunk
      raise Errors::UnexpectedEof if next_chunk.nil?
      Util::Logger.debug 'READ: '.yellow + "\"#{next_chunk}\""
      @chunks << next_chunk unless whitespace? next_chunk
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
        value.gsub(/[#{WHITESPACE}]*\n[#{WHITESPACE}]*/, '')
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

    # TODO: Allow tabs as well?
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
      return if @last_token_type == Token::RETURN

      @stack += [
        Token.new(Token::PARAMETER, '無', particle: 'を', sub_type: Token::VAL_NULL),
        Token.new(Token::RETURN)
      ]
    end

    def try_assignment_close
      return false unless eol? @reader.peek_next_chunk

      if @context.inside_array?
        @stack << Token.new(Token::ARRAY_CLOSE)
        @context.inside_array = false
      end

      close_assignment
    end

    def close_assignment
      assignment_token = @stack.first

      # TODO: (v1.1.0) or 1st token is PROPERTY and 2nd is ASSIGNMENT
      unless assignment_token.type == Token::ASSIGNMENT
        raise Errors::UnexpectedInput, assignment_token.content || assignment_token.to_s.upcase
      end

      @context.inside_assignment = false
      @current_scope.add_variable assignment_token.content

      # @tokens << assignment_token
      # @tokens += @stack
      # @stack.clear
    end

    def close_if_statement(comparison_tokens = [])
      raise Errors::UnexpectedComparison unless @context.inside_if_condition?

      validate_logical_operation

      @stack.insert 1, *comparison_tokens unless comparison_tokens.empty?
      # @tokens += comparison_tokens unless comparison_tokens.empty?
      # @tokens += @stack
      # @stack.clear

      @context.inside_if_condition = false
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

      # Something else was in the stack
      # raise Errors::UnexpectedFunctionCall, function[:name] unless @stack.empty?

      num_parameters = parameter_tokens.count(&:particle)
      if num_parameters == 1 && function[:built_in?] && BuiltIns.math?(function[:name])
        parameter_tokens.unshift Token.new Token::PARAMETER, 'それ', sub_type: Token::VAR_SORE
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

      if @last_token_type == Token::PROPERTY
        property_token = @stack.last
        parameter_token = Token.new Token::ATTRIBUTE, chunk, sub_type: attribute_type(chunk)
        validate_property_and_attribute property_token, parameter_token
      else
        raise Errors::VariableDoesNotExist, chunk unless rvalue? chunk
        parameter_token = Token.new Token::RVALUE, chunk, sub_type: variable_type(chunk)
      end

      parameter_token
    end

    # TODO: replace with a check for no comp_1 ?
    def stack_is_truthy_check?
      # (@stack.size == 1 && @stack.first.type == Token::RVALUE) ||
      #   (@stack.size == 2 && @stack.first.type == Token::PROPERTY) ||
      #   (@stack.size >= 1 && @stack.last.type == Token::FUNCTION_CALL)
      (@stack.size == 2 && @stack[1].type == Token::RVALUE) ||
        (@stack.size == 3 && @stack[1].type == Token::PROPERTY) ||
        (@stack.size >= 2 && @stack.last.type == Token::FUNCTION_CALL)
    end

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
