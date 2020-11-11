require_relative '../colour_string'
require_relative '../token'
require_relative '../util/logger'
require_relative '../util/options'

require_relative 'errors'
require_relative 'formatter'
require_relative 'return_value'
require_relative 'scope'

require_relative 'processor/built_ins'

module Interpreter
  class Processor

    MAX_CALL_STACK_DEPTH = 1000;

    include BuiltIns

    def initialize(lexer, options = {})
      @lexer   = lexer
      @options = options

      @current_scope = Scope.new

      # The current stack of tokens to be processed.
      @stack = []
    end

    def execute
      process
    rescue Errors::BaseError => e
      e.line_num = @lexer.line_num
      raise
    end

    private

    def process
      raise Errors::CallStackTooDeep, MAX_CALL_STACK_DEPTH if caller.length > MAX_CALL_STACK_DEPTH

      loop do
        token = next_token
        break if token.nil?

        value = process_token token
        return value if value.is_a? ReturnValue
      end

      nil
    end

    def next_token
      token = peek_next_token
      Util::Logger.debug Util::Options::DEBUG_2, 'RECEIVE: '.lred + (token ? "#{token} #{token.content}" : 'EOF')
      @current_scope.advance
      token
    end

    def peek_next_token
      if @current_scope.type == Scope::TYPE_MAIN
        token = @lexer.next_token
        @current_scope.tokens << token unless token.nil?
      end
      @current_scope.current_token
    end

    def next_token_if(token_type)
      next_token if peek_next_token&.type == token_type
    end

    # Accumulates tokens until the requested token type.
    # If searching for a SCOPE_CLOSE: skips pairs of matching SCOPE_BEGINS and
    # SCOPE_CLOSEs.
    def accept_until(token_type, options = { inclusive?: true })
      [].tap do |tokens|
        open_count = 0

        loop do
          peeked_token = peek_next_token

          open_count += 1 if token_type == Token::SCOPE_CLOSE && peeked_token.type == Token::SCOPE_BEGIN

          if peeked_token.type == token_type
            break if open_count.zero?
            open_count -= 1
          end

          tokens << next_token
        end

        tokens << next_token if options[:inclusive?]
      end
    end

    # TODO: (v1.0.0) maybe clear the stack after processing?
    def process_token(token)
      token_type = token.type.to_s
      method = "process_#{token_type}"
      if respond_to? method, true
        Util::Logger.debug Util::Options::DEBUG_2, 'PROCESS: '.lyellow + token_type
        return send method, token
      end
      @stack << token
    end

    # Processors
    # TODO: (v1.0.0) Move these out similarly to the lexer
    ############################################################################

    def process_assignment(token)
      # TODO: (v1.1.0) Check for property in the stack
      value_token = next_token

      case value_token.type
      when Token::RVALUE
        value = resolve_variable value_token
        value = boolean_cast value if !next_token_if(Token::QUESTION).nil?
      when Token::PROPERTY
        # TODO: feature/properties
      when Token::ARRAY_BEGIN
        tokens = accept_until Token::ARRAY_CLOSE
        tokens.pop # discard close
        value = [].tap do |elements|
          tokens.chunk { |t| t.type == Token::COMMA } .each do |is_comma, chunk|
            next if is_comma

            case chunk[0].type
            when Token::RVALUE
              value = resolve_variable chunk[0]
              value = boolean_cast value if chunk[1]&.type == Token::QUESTION
            when Token::PROPERTY
              # TODO: feature/properties
            end

            elements << value
          end
        end
      end

      # TODO: (v1.1.0) Check for property in the stack
      if token.sub_type == Token::VARIABLE
        @current_scope.set_variable token.content, value
      elsif token.sub_type == Token::VAR_ARE
        @are = value
      end

      @sore = value

      Util::Logger.debug Util::Options::DEBUG_2, "#{token.content} = #{value} (#{value.class})".lpink
    end

    def process_debug(_token)
      debug_message = [
        @current_scope.to_s,
        'それ: ' + Formatter.output(@sore),
        'あれ: ' + Formatter.output(@are),
      ].join "\n"
      Util::Logger.debug Util::Options::DEBUG_3, debug_message.lblue
      exit if peek_next_token&.type == Token::BANG
    end

    def process_no_op(_token)
      # pass
    end

    def process_function_def(token)
      parameter_particles = @stack.map(&:particle)
      function_key = token.content + parameter_particles.sort.join

      # skip if already defined
      return if @current_scope.get_function function_key, bubble_up?: false

      next_token # discard scope open
      tokens = accept_until Token::SCOPE_CLOSE
      tokens.pop # discard scope close
      @current_scope.define_function function_key, tokens, @stack.map(&:content)

      @stack.clear

      Util::Logger.debug Util::Options::DEBUG_2, "define #{token.content} (#{parameter_particles.join ','})".lpink
    end

    def process_function_call(token)
      parameter_particles = @stack.map(&:particle)
      function_key = token.content + parameter_particles.sort.join

      arguments = @stack.dup
      @stack.clear

      # TODO: feature/properties
      resolved_arguments = arguments.map do |parameter_token|
        resolve_variable parameter_token
      end

      function = @current_scope.get_function function_key

      Util::Logger.debug(
        Util::Options::DEBUG_2,
        "call #{resolved_arguments.zip(parameter_particles).map(&:join).join}#{token.content}".lpink
      )

      is_loud = !next_token_if(Token::BANG).nil?
      is_inquisitive = !next_token_if(Token::QUESTION).nil?

      if function.nil?
        return delegate_built_in token.content, arguments, allow_error?: is_loud, cast_to_boolean?: is_inquisitive
      end

      function.parameters.zip(resolved_arguments).each do |name, argument|
        function.set_variable name, argument
      end

      current_scope = @current_scope # save current scope
      @current_scope = function      # swap current scope with function
      @current_scope.reset           # reset the token pointer
      begin
        @sore = process.value        # process function tokens
        @sore = boolean_cast @sore if is_inquisitive
      rescue Errors::BaseError => e
        raise e if is_loud
        @sore = nil
      end
      @current_scope = current_scope # replace current scope
    end

    def process_return(_token)
      # TODO: feature/properties
      ReturnValue.new resolve_variable @stack.pop
    end

    def process_loop(_token)
      start_index = 0
      end_index = Float::INFINITY

      if @stack.last&.type == Token::LOOP_ITERATOR
        # TODO: (v1.1.0) Check for property
        target = resolve_variable @stack.first
        raise Errors::ExpectedContainer unless [Array, String].include? target.class
        end_index = target.length
      elsif !@stack.empty?
        # TODO: feature/properties
        start_index = resolve_variable(@stack[0]).to_i
        end_index = resolve_variable(@stack[1]).to_i
      end
      @stack.clear

      next_token # discard scope open
      tokens = accept_until Token::SCOPE_CLOSE
      tokens.pop # discard scope close

      current_scope = @current_scope                                       # save current scope
      @current_scope = Scope.new(@current_scope, Scope::TYPE_LOOP, tokens) # swap current scope with loop scope

      value = nil
      (start_index ... end_index).each do |i|
        @current_scope.reset
        @sore = target ? target[i] : i
        value = process
        if value.is_a? ReturnValue
          next if value.value == Token::NEXT
          break
        end
      end

      @current_scope = current_scope # replace current scope

      value if value.is_a?(ReturnValue) && value.value != Token::BREAK
    end

    def process_next(_token)
      ReturnValue.new Token::NEXT
    end

    def process_break(_token)
      ReturnValue.new Token::BREAK
    end

    def process_if(_token)
      comparator_token = next_token

      comparison_tokens = accept_until Token::SCOPE_BEGIN, inclusive?: false
      if comparison_tokens.last.type == Token::FUNCTION_CALL
        # TODO: feature/interpreter_if-function-call
      else
        # TODO: feature/properties
        comparator1 = resolve_variable comparison_tokens[0]
        comparator2 = resolve_variable comparison_tokens[1]
        comparator2 = boolean_cast comparator2 if comparison_tokens.last.type == Token::QUESTION
      end

      comparator = {
        Token::COMP_LT   => :'<',
        Token::COMP_LTEQ => :'<=',
        Token::COMP_EQ   => :'==',
        Token::COMP_NEQ  => :'!=',
        Token::COMP_GTEQ => :'>=',
        Token::COMP_GT   => :'>',
      }[comparator_token.type]

      next_token # discard scope open
      body_tokens = accept_until Token::SCOPE_CLOSE
      body_tokens.pop # discard scope close

      if [comparator1, comparator2].reduce comparator
        current_scope = @current_scope                                                # save current scope
        @current_scope = Scope.new(@current_scope, Scope::TYPE_IF_BLOCK, body_tokens) # swap current scope with if scope

        value = process

        @current_scope = current_scope # replace current scope

        # TODO: feature/interpreter_if-else-else kill any following else-ifs or elses
      end
      # TODO: feature/interpreter_if-else-else

      value
    end

    # Helpers
    ############################################################################

    # TODO: feature/properties resolve_variable!
    # * pass in container
    # * shift from conainer and resolve
    # * shift again if property
    # * return resolved value (and leave container modified)
    def resolve_variable(token)
      case token.sub_type
      when Token::VAL_NUM   then token.content.to_f
      when Token::VAL_STR   then token.content.gsub(/^「/, '').gsub(/」$/, '')
      when Token::VAL_TRUE  then true
      when Token::VAL_FALSE then false
      when Token::VAL_NULL  then nil
      when Token::VAL_ARRAY then []
      when Token::VAR_SORE  then copy_special @sore
      when Token::VAR_ARE   then copy_special @are
      when Token::VARIABLE  then copy_special @current_scope.get_variable token.content
      end
    end

    # TODO: feature/interpreter-properties
    # def resolve_property(property_token, attribute_token)
    # end

    def copy_special(value)
      [String, Array, Hash].include?(value.class) ? value.dup : value
    end

    def boolean_cast(value)
      return !value.zero?  if value.is_a? Numeric
      return !value.empty? if value.is_a?(String) || value.is_a?(Array)
      return false         if value.is_a?(FalseClass)
      !value.nil?
    end
  end
end
