require_relative '../colour_string'
require_relative '../token'
require_relative '../util/logger'
require_relative '../util/options'

require_relative 'scope'
require_relative 'return_value'

module Interpreter
  class Processor
    def initialize(lexer, options = {})
      @lexer   = lexer
      @options = options

      @current_scope = Scope.new

      # The current stack of tokens to be processed.
      @stack = []
    end

    # TODO: (v1.0.0) Catch errors and get line number from lexer
    # Show full stack trace if in debug mode
    def execute
      process
    rescue => e
      raise e if @options[:debug] != Util::Options::DEBUG_OFF
      puts e.message
      nil
    end

    private

    def process
      raise 'TODO: error' if caller.length > 1000

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

      if token.sub_type == Token::VARIABLE
        @current_scope.set_variable token.content, value
      elsif token.sub_type == Token::VAR_ARE
        @are = value
      end

      @sore = value

      Util::Logger.debug Util::Options::DEBUG_2, "#{token.content} = #{value} (#{value.class})".lpink
    end

    def process_debug(_token)
      Util::Logger.debug Util::Options::DEBUG_3, "#{@current_scope}\nそれ: #{@sore}\nあれ: #{@are}".lblue
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

      function = @current_scope.get_function function_key

      # TODO: feature/interpreter-built-ins
      # If built-in, delegate to built-in function methods instead

      # TODO: feature/properties
      arguments = @stack.map do |parameter_token|
        resolve_variable parameter_token
      end
      @stack.clear

      function.parameters.zip(arguments).each do |name, argument|
        function.set_variable name, argument
      end

      Util::Logger.debug(
        Util::Options::DEBUG_2,
        "call #{arguments.zip(parameter_particles).map(&:join).join}#{token.content}".lpink
      )

      is_loud = !next_token_if(Token::BANG).nil?

      current_scope = @current_scope.dup # save current scope
      @current_scope = function          # swap current scope with function
      @current_scope.reset               # reset the token pointer
      begin
        @sore = process.value              # process function tokens
      rescue => e
        raise e if is_loud
        @sore = nil
      end
      @current_scope = current_scope     # replace current scope
    end

    def process_return(_token)
      # TODO: feature/properties
      ReturnValue.new resolve_variable @stack.pop
    end

    # TODO: feature/interpreter-loop
    # def process_loop(loop_token)
    #   # Get parameters
    #   # Make a new scope and fill with tokens until scope_close
    #   # From (start_parameter || 0) to (end_parameter || Float::Infinity)
    #   # @sore = loop index
    #   # Call process
    #   # If !return_value.is_a?(ReturnValue) || return_value.value == Token::NEXT, continue
    #   # If return_value.value == Token::BREAK, break
    #   # Else return return_value
    # end

    # Helpers
    ############################################################################

    def resolve_variable(token)
      case token.sub_type
      when Token::VAL_NUM   then token.content.to_f
      when Token::VAL_STR   then token.content.tr '「」', ''
      when Token::VAL_TRUE  then true
      when Token::VAL_FALSE then false
      when Token::VAL_NULL  then nil
      when Token::VAL_ARRAY then []
      when Token::VAR_SORE  then copy_special @sore
      when Token::VAR_ARE   then copy_special @are
      when Token::VARIABLE  then @current_scope.get_variable token.content
      end
    end

    # TODO: feature/interpreter-properties
    # def resolve_property(property_token, attribute_token)
    # end

    def copy_special(value)
      value.is_a?(String) || value.is_a?(Array) ? value.dup : value
    end

    def boolean_cast(value)
      return !value.zero?  if value.is_a? Numeric
      return !value.empty? if value.is_a?(String) || value.is_a?(Array)
      return false         if value.is_a?(FalseClass)
      !value.nil?
    end
  end
end
