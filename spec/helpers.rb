require 'tempfile'

module Helpers
  def make_test_file(contents)
    file = Tempfile.new('testfile')
    file.write contents.join "\n"
    file.close

    file.path
  end
end
