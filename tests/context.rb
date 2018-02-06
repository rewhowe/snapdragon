require 'tempfile'

SNAPDRAGON = File.join(File.dirname(__FILE__), '..', 'snapdragon')

def token_test(test_name, *parameters)
  input, output = parameters.transpose

  tempfile = Tempfile.new(test_name.gsub(/\s/, '_').gsub(/\(|\)/, ''))

  tempfile.write(input.join("\n"))
  tempfile.close

  result = `#{SNAPDRAGON} #{tempfile.path} --debug --tokens-only`

  begin
    output.zip(result.split("\n")).each do |expected, actual|
      # slice off the formatting \e[xxm
      if actual.gsub(/\e\[\d\d?m/, '') != expected
        raise "\nFailure during '#{test_name}'" +
          "\n  Expected: #{expected}" +
          "\n  Actual:   #{actual}" +
          "\n\n" +
          "Result:\n#{result}\n"
      end
    end
    print '.'
  rescue => e
    puts 'F', e
  end

  tempfile.delete
end
