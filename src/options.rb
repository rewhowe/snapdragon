def read_options
  print_usage if should_print_usage?

  options = {}

  ARGV.each do |arg|
    case arg
    when '-d', '--debug'
      options[:debug] = true
    when '-t', '--tokens'
      options[:tokens] = true
    when /^-l=.+/, /^--lang=.+/
      options[:language] = arg.gsub(/^(-l|--lang)=/, '')
    when /^-o=.+/
      options[:output] = arg.gsub(/^-o=/, '')
    else
      validate_filename arg, options
      options[:filename] = arg
    end
  end

  validate_options options

  options
end

def print_usage
  abort "Usage: #{$PROGRAM_NAME} [options] sourcefile\n" \
    "Options:\n" \
    "  -d, --debug     Print various debugging information to stdout\n" \
    "  -t, --tokens    Print tokens and exit\n" \
    "  -l=outputlanguage, --lang=outputlanguage\n" \
    "                  Output language (see below)\n" \
    "  -o=outputfile   Output file path (default is local directory with same filename)\n" \
    "Languages:\n" \
    "  TODO\n"
end

def should_print_usage?
  ARGV.empty? || ARGV.include?('-h') || ARGV.include?('--help')
end

def validate_filename(arg, options)
  return if arg !~ /^-/ && options[:filename].nil?
  abort "#{$PROGRAM_NAME}: Invalid option #{arg} (use -h for usage details)"
end

def validate_options(options)
  abort 'Language not specified (use -h for usage details)' if options[:language].nil?
  abort "Input file (#{options[:filename]}) not found" if options[:filename].nil? || !File.exist?(options[:filename])
end
