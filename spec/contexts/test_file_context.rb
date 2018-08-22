require 'tempfile'

RSpec.shared_context 'uses_test_file' do
  before :all do
    @test_file = Tempfile.new('testfile')
  end

  after :all do
    @test_file.delete
  end

  def write_test_file(contents)
    @test_file.open
    @test_file.truncate 0
    @test_file.write contents.join "\n"
    @test_file.close
  end

  def test_file_path
    @test_file.path
  end
end
