def get_options
  if ARGV.empty? || ARGV.include?('-h') || ARGV.include?('--help')
    abort "Usage: #{$0} [switches] sourcefile\n" +
      "  -d, --debug     Print various debugging information to stdout\n" +
      "  -t, --tokens    Print tokens and exit\n" +
      "  -l=outputlanguage, --lang=outputlanguage\n" +
      "                  Output language (see below)\n" +
      "  -o=outputfile   Output file path (default is local directory with same filename)\n" +
      "Available languages:\n" +
      "  TODO"
  end

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
      if arg !~ /^-/ && options[:filename].nil?
        options[:filename] = arg
      else
        abort "#{$0}: Invalid option #{arg} (use -h for usage details)"
      end
    end
  end

  abort "Input file (#{options[:filename]}) not found" if options[:filename].nil? || !File.exist?(options[:filename])

  options
end
