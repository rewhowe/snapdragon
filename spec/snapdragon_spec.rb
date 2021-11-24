require './spec/contexts/test_file'

RSpec.describe 'Snapdragon', 'command line execution' do
  include_context 'test_file'

  describe 'options' do
    ##
    # Functionally equivalent to -h and --help options
    it 'shows a usage message when there are no arguments' do
      expect { system('./snapdragon') } .to output(/\A\s+Usage/).to_stdout_from_any_process
    end

    it 'can show various levels of debug messages' do
    end

    it 'can set error message language' do
    end

    it 'can print only tokens' do
    end

    it 'can enter interactive mode' do
    end

    it 'can show version information' do
    end

    it 'can separate arguments from options' do
    end

    it 'cannot accept -i and -t together' do
    end

    it 'shows an error when the input file is not found' do
      expect do
        system('./snapdragon does_not_exist.sd')
      end .to output("Input file (does_not_exist.sd) not found\n").to_stderr_from_any_process
    end
  end

  describe 'interactive mode' do
  end
end
