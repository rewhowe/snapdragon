module Util
  class Options
    private_class_method :new

    DEBUG_1   = 1 # everything
    DEBUG_2   = 2 # interpreter only
    DEBUG_3   = 3 # debug command only (default level if switch is present)
    DEBUG_OFF = 9 # no debug (default)

    LANG_EN = 'en'.freeze # en-CA (default)
    LANG_JA = 'ja'.freeze # ja-JP

    class << self
      # rubocop:disable Metrics/CyclomaticComplexity
      def parse_arguments
        print_usage if should_print_usage?

        options = { debug: DEBUG_OFF, lang: LANG_EN, argv: [] }

        until ARGV.empty? do
          arg = ARGV.shift

          case arg
          when /^(-d|--debug)\d?$/   then set_debug_level arg, options
          when /^(-l|--lang)=\w{2}$/ then set_lang arg, options
          when '-t', '--tokens'      then options[:tokens] = true
          when '-v', '--version'     then options[:version] = true
          when '--'                  then options[:argv] += ARGV.slice! 0..-1
          when /^-/                  then print_invalid_option arg
          else
            options[:argv] << arg
          end
        end

        options[:filename] = options[:argv].first
        validate_options options

        options
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      private

      def print_usage
        puts %(\
  Usage: #{$PROGRAM_NAME} [options] sourcefile
  Options:
    -d, --debug[level:3]   Print various debugging information to stdout
                           level: 1 = verbose, 2 = execution only, 3 = debug messages only (default)
    -l, --lang=<code:en>   Set error message language
                           code: en = English (en-CA), ja = 日本語 (ja-JP)
    -t, --tokens           Print tokens and exit
    -v, --version          Print version and exit
    --                     Separate following arguments from preceding options
)
        exit
      end

      def print_invalid_option(arg)
        abort "#{$PROGRAM_NAME}: Invalid option #{arg} (use -h for usage details)"
      end

      def should_print_usage?
        ARGV.empty? || ARGV.include?('-h') || ARGV.include?('--help')
      end

      def set_debug_level(arg, options)
        level = (arg.match(/(\d)$/)&.captures&.first || DEBUG_3).to_i
        print_invalid_option arg unless [DEBUG_1, DEBUG_2, DEBUG_3].include? level
        options[:debug] = level
      end

      def set_lang(arg, options)
        lang = arg.match(/(\w{2})$/).captures.first
        print_invalid_option arg unless [LANG_EN, LANG_JA].include? lang
        options[:lang] = lang
      end

      def validate_options(options)
        return if options[:version] || File.exist?(options[:filename].to_s)
        abort "Input file (#{options[:filename]}) not found"
      end
    end
  end
end
