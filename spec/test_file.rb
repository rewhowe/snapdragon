require 'tempfile'

module TestFile
  def write_contents(contents)
    @test_file.open.truncate 0
    @test_file.write contents.join "\n"
    @test_file.close
  end

  begin
    before :all do
      puts 'before all'
      @test_file = Tempfile.new('testfile')
    end

    after :all do
      puts 'after all'
      @test_file.delete
    end
  end
end
