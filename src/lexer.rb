require File.join(File.dirname(__FILE__), 'scope.rb')
require File.join(File.dirname(__FILE__), 'conjugator.rb')

class Lexer
  PARTICLE  = '(?:から|と|に|へ|まで|で|を)'.freeze # 使用可能助詞
  COUNTER   = %w(つ 人 個 匹 子 頭).freeze          # 使用可能助数詞
  WS  = '[\s,　、]'.freeze                          # 空白文字
  NWS = '[^\s,　、]'.freeze                         # 通常文字

  class << self

    def tokenize(filename, options)
      if options[:debug] && !options[:tokens_only]
        puts filename
        puts options
      end

      @options = options

#      tokenized_lines = []
      @scopes = []
      @scopes << Scope.new

      File.foreach(filename).with_index(1) do |line, index|
        begin

          puts 'READ: ' + line if @options[:debug] && !@options[:tokens_only]

          @line = line

          clean

          process_indent

          # TODO: process suffix

          tokens = match_newline ||
                   match_no_op ||
                   match_function_definition ||
                   match_variable_assignment ||
                   match_ambiguous ||
                   no_match

  #        tokenized_lines << ([:indent] * indent_level) + tokens

          update_scope(tokens)
          print_tokens(tokens) if @options[:debug]
        rescue => e
          puts "Error occured while tokenizing on line #{index}"
          puts e.message
        end
      end
    end

    private

    def clean
      # TODO: bracket inside string
      @line = @line.gsub(/(\(|（).*$/, '') # comment
                   .gsub(/#{WS}*$/, '')    # trailing whitespace
    end

    def process_indent
      indent_level = 0

      if indented_line = @line.match(/^(#{WS}+)(.*)$/)
        indent_level += indented_line.captures.first.count(' ')
        indent_level += indented_line.captures.first.count('　')
        @line = indented_line.captures.last
      end

      if indent_level > @scopes.last.level
        puts 'indenting'
      elsif indent_level < @scopes.last.level
        puts 'outdenting'
      end
    end

    def match_newline
      if @line.empty?
        [type: :newline]
      end
    end

    def match_no_op
      if @line =~ /^・・・/
        error('Extra characters after no-op') unless @line =~ /^・・・$/
        [type: :no_op]
      end
    end

    def match_function_definition
      if match = /^(.+)#{WS}+とは$/.match(@line)
        signature = match.captures.first
        params, name = parse_function_signature(signature, is_defintion: true)

        unless Conjugator::is_verb?(name)
          error("#{name} doesn't look like a verb?")
        end

        [
          type: :function_definition,
          function_name: name,
          params: params,
        ]
      end
    end

    def match_variable_assignment
      if match = /^(#{NWS}+)#{WS}+は#{WS}+(#{NWS}+)$/.match(@line)
        variable, value = match.captures

        if is_value?(value)
          [
            type: :variable_assignment,
            variable_name: variable,
            value: value,
          ]
        else
          error("undefined variable: #{value}")
        end
      end
    end

    def match_ambiguous
      match1 = match_ambiguous_variable_assignment
      match2 = match_ambiguous_function_call

      if (!!match1) ^ (!!match2)
        [match1, match2].find { |m| !!m }
      elsif match1 && match2
        error('ambiguous match')
      end
      # TODO: match other ambiguous things
    end

    def match_ambiguous_variable_assignment
      if @line =~ /^#{NWS}+#{WS}*は#{WS}*#{NWS}+$/
        i = 0
        while i = @line.index('は', i + 1)
          variable = @line[0...i]
          value = @line[(i + 1)..-1]

          return if value.empty?

          if is_value?(value)
            return [
              type: :variable_assignment,
              variable_name: variable,
              value: value,
            ]
          end
        end
      end
    end

    def match_ambiguous_function_call
      params, name = parse_function_signature(@line)

      return if name.nil?

      params.each do |variable, _particle|
        unless @scopes.last.has_variable?(variable) || is_value?(variable)
          error("parameter #{variable} is undefined")
        end
      end

      [
        type: :function_call,
        function_name: name,
        params: params,
      ]
    end

    def no_match
      [type: :misc, token: @line.clone]
    end

    def parse_function_signature(signature, options={})
      # no separators? the entire signature is the function name
      if options[:is_definition] && (signature =~ /#{WS}/).nil?
        return [[], signature]
      end

      match = /^(.*)#{WS}+(#{NWS}+)$/.match(signature)
      params_with_particles, name = match.captures if match

      return if name.nil? || name.empty? || !@scopes.last.has_function?(name)

      params = []

      while params_with_particles
        match = /^(#{NWS}+?)#{WS}*(#{PARTICLE})#{WS}*/.match(params_with_particles)

        if match
          params << [match.captures.first, match.captures.last]
          params_with_particles.gsub!(/^#{NWS}+?#{WS}*#{PARTICLE}#{WS}*/, '')
        else
          unless params_with_particles.empty?
            error("Unexpected #{params_with_particles} in function signature")
            return # TODO: remove?
          end
          break
        end
      end
#      *params_with_particles, name = signature.split(/#{WS}+/)
#
#      params = params_with_particles.map do |param|
#        match = /^(.+?)(#{PARTICLE})$/.match(param)
#
#        unless match
#          error("invalid format of param #{param} in definition of #{name}")
#          next # TODO: remove
#        end
#
#        match.captures
#      end

      return [params, name]
    end

    def update_scope(tokens)
      case tokens.first[:type]
      when :variable_assignment
        @scopes.last.add_variable(tokens.first[:variable_name])
      when :function_definition
        @scopes.last.add_function(tokens.first[:function_name])
        # TODO: should probably save the signature as well?
      else
      end
    end

    def error(message)
      if @options[:debug]
        puts "\e[31m#{message}\e[0m"
      else
        raise message
      end
    end

    def print_tokens(tokens)
      puts "\e[32m#{tokens.inspect}\e[0m"
    end

    def is_value?(value)
      return value =~ /^-?(\d+\.\d+|\d+)$/ ||
             value =~ /^「[^」]*」$/       ||
             @scopes.last.has_variable?(value)
    end
  end
end
