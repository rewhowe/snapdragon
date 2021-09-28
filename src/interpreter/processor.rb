require_relative '../string'
require_relative '../token'
require_relative '../util/i18n'
require_relative '../util/logger'
require_relative '../util/options'
require_relative '../tokenizer/constants'

require_relative 'errors'
require_relative 'formatter'
require_relative 'return_value'
require_relative 'scope'
require_relative 'sd_array'

require_relative 'processor/built_ins'
require_relative 'processor/conditionals'
require_relative 'processor/resolvers'
require_relative 'processor/validators'
Dir["#{__dir__}/processor/token_processors/*.rb"].each { |f| require_relative f }

module Interpreter
  class Processor
    MAX_CALL_STACK_DEPTH = 1000

    ############################################################################
    # TokenProcessors consist of processing methods and any processing-specific
    # helper methods.
    #
    # Processing:
    # These methods take tokens and execute them. They may also read from the
    # stack or additional tokens in the token stream. The stack should be clear
    # after each call to a processing method.
    #
    # Any other common or helper methods will be in this file.
    ############################################################################
    include TokenProcessors

    ############################################################################
    # Built-In function implementations.
    ############################################################################
    include BuiltIns

    ############################################################################
    # Methods specifically for conditional evaluation (shared by IF and WHILE).
    ############################################################################
    include Conditionals

    ############################################################################
    # Methods for resolving variables and properties.
    ############################################################################
    include Resolvers

    ############################################################################
    # Exactly What It Says On The Tin™
    ############################################################################
    include Validators

    def initialize(lexer, options = { argv: [] })
      @lexer   = lexer
      @options = options

      @current_scope = Scope.new
      @current_scope.set_variable Tokenizer::ID_ARGV, SdArray.from_array(@options[:argv])
      @current_scope.set_variable Tokenizer::ID_ERR, nil

      # The current stack of tokens which have not been processed.
      @stack = []
      @line_num = 0
    end

    def execute
      process
    rescue Errors::BaseError => e
      e.line_num = @line_num
      raise
    end

    private

    def process
      raise Errors::CallStackTooDeep, MAX_CALL_STACK_DEPTH if caller.length > MAX_CALL_STACK_DEPTH

      loop do
        token = next_token
        break if token.nil?

        result = process_token token
        return result if result.is_a? ReturnValue
      end

      nil
    end

    ##
    # If this is the main scope, tokens are read from the lexer and discarded.
    # Otherwise, the tokens of other types of scopes are stored in their bodies
    # and kept track of using a token pointer.
    # Returns the current token under the token pointer and then optionally
    # advances it.
    def next_token(options = { should_advance?: true })
      if @current_scope.type == Scope::TYPE_MAIN && @current_scope.current_token.nil?
        token = @lexer.next_token
        @current_scope.tokens << token unless token.nil?
      end

      token = @current_scope.current_token

      if options[:should_advance?]
        Util::Logger.debug(Util::Options::DEBUG_2) do
          Util::I18n.t('interpreter.receive').lred + (token ? "#{token} #{token.content}" : 'EOF')
        end
        @current_scope.advance
      end

      token
    end

    def peek_next_token
      next_token should_advance?: false
    end

    def next_token_if(token_type)
      next_token if peek_next_token&.type == token_type
    end

    ##
    # Accumulates tokens until the requested token type.
    # If searching for a SCOPE_CLOSE: skips pairs of matching SCOPE_BEGINS and
    # SCOPE_CLOSEs.
    def next_tokens_until(token_type, options = { inclusive?: true })
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

    def next_tokens_from_scope_body
      next_token # discard scope open
      body_tokens = next_tokens_until Token::SCOPE_CLOSE
      body_tokens.pop # discard scope close
      body_tokens
    end

    ##
    # Calls the associated processing method if the current token can lead to
    # meaningful execution. Otherwise, stores the token in the stack to be
    # processed later.
    # Line num is only updated in the main scope - this loses some information for
    # nested loops, but unfortunately line number is generally discared while
    # tokenizing
    def process_token(token)
      token_type = token.type.to_s
      method = "process_#{token_type}"

      return @stack << token unless respond_to? method, true

      @line_num = @lexer.line_num if @current_scope.type == Scope::TYPE_MAIN

      Util::Logger.debug(Util::Options::DEBUG_2) { Util::I18n.t('interpreter.process').lyellow + token_type }
      send method, token
    end

    ##
    # Saves the current scope, swaps to the given scope, yields, then returns
    # to the original scope.
    def with_scope(scope)
      current_scope = @current_scope
      @current_scope = scope
      result = yield
      @current_scope = current_scope
      result
    end

    # Helpers
    ############################################################################

    ##
    # Returns a copy of a value (to prevent modifying the original).
    # MUST be used with SdArrays before modification.
    # MUST be used on values before assignment (including setting properties).
    def copy_special(value)
      case value
      when String  then value.dup
      when SdArray then SdArray.from_sd_array value
      else value
      end
    end

    def boolean_cast(value)
      case value
      when Numeric         then !value.zero?
      when String, SdArray then !value.empty?
      when FalseClass      then false
      else                      !value.nil?
      end
    end

    def set_variable(tokens, value)
      if tokens.first.type == Token::POSSESSIVE
        set_property tokens, value
      elsif tokens.first.sub_type == Token::VARIABLE
        @current_scope.set_variable tokens.first.content, value
      elsif tokens.first.sub_type == Token::VAR_ARE
        @are = value
      end
    end

    # NOTE: While Numeric is a valid property owner, there are presently no
    # properties that belong to numeric which are mutable.
    def set_property(tokens, value)
      property_owner_token = tokens.shift

      property_owner = get_property_owner property_owner_token

      validate_type [String, SdArray], property_owner

      case property_owner
      when String  then set_string_property property_owner, tokens.shift, value
      when SdArray then set_array_property property_owner, tokens.shift, value
      end

      if property_owner_token.sub_type == Token::VAR_ARE
        @are = property_owner
      elsif property_owner_token.sub_type == Token::VARIABLE
        @current_scope.set_variable property_owner_token.content, property_owner
      end
    end

    ##
    # When changing properties of sore / are, we need to make a copy to avoid
    # modifying the original values.
    def get_property_owner(property_owner_token)
      case property_owner_token.sub_type
      when Token::VAR_SORE then copy_special @sore
      when Token::VAR_ARE  then copy_special @are
      else @current_scope.get_variable property_owner_token.content
      end
    end

    def set_string_property(property_owner, property_token, value)
      index = case property_token.sub_type
              when Token::PROP_FIRST then 0
              when Token::PROP_LAST  then property_owner.length - 1
              else resolve_variable! [property_token]
              end

      raise Errors::InvalidStringProperty, property_token.content unless valid_string_index? property_owner, index
      property_owner[index] = Formatter.interpolated value
    end

    def set_array_property(property_owner, property_token, value)
      case property_token.sub_type
      when Token::PROP_FIRST then property_owner.first = value
      when Token::PROP_LAST  then property_owner.last = value
      else
        key = resolve_variable! [property_token]
        property_owner.set key, value
      end
    end

    def function_indentifiers_from_stack(token)
      parameter_particles = @stack.map(&:particle).compact
      [token.content + parameter_particles.sort.join, parameter_particles]
    end
  end
end
