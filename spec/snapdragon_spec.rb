require './spec/contexts/test_file'
require 'readline'

RSpec.describe 'Snapdragon', 'command line execution' do
  include_context 'test_file'
  # include_context 'processor'
      # allow($stderr).to receive(:write) # suppress stderr
      # expect($stdout).to receive(:write).with 'usage'
      #   output = capture_standard_output { game.ask_for_name }
      # expect(output).to eq "What shall I call you today?"
      # allow(STDIN).to receive(:gets) { 'joe' }
      # expect(game.ask_for_name).to eq 'Joe'

  describe 'options' do
    ##
    # Functionally equivalent to -h and --help options
    it 'shows a usage message when there are no arguments' do
      expect { system './snapdragon' } .to output(/\A\s+Usage/).to_stdout_from_any_process
    end

    it 'can show various levels of debug messages' do
      write_test_file "「こんにちは、世界！」を ポイ捨てる\n"

      # debug off
      expect { system "./snapdragon #{test_file_path}" } .to_not output.to_stdout_from_any_process

      {
        1 => { output: /TRY:/, not_output: '' },
        2 => { output: /RECEIVE:/, not_output: /TRY:/ },
        3 => { output: /こんにちは、世界！/, not_output: /RECEIVE:/ },
      }.each do |level, test|
        expect_command = expect { system "./snapdragon -d#{level} #{test_file_path}" }
        expect_command.to output(test[:output]).to_stdout_from_any_process
        expect_command.to_not output(test[:not_output]).to_stdout_from_any_process
      end
    end

    it 'can set error message language' do
      write_test_file "1を 0で 割る\n"

      {
        en: /Division by zero/,
        ja: /ゼロ除算/,
      }.each do |lang, error|
        expect do
          system "./snapdragon -l=#{lang} #{test_file_path}"
        end .to output(error).to_stderr_from_any_process
      end
    end

    it 'can print only tokens' do
      write_test_file "「こんにちは、世界！￥ｎ」と 言う\n"

      expected_output = (
        "\e[34mparameter\e[0m 「こんにちは、世界！￥ｎ」 \e[34mval_str\e[0m\n" \
        "\e[34mfunction_call\e[0m PRINT \e[34mfunc_built_in\e[0m\n"
      )
      expect do
        system("./snapdragon -t #{test_file_path}")
      end .to output(expected_output).to_stdout_from_any_process
    end

    it 'can enter interactive mode' do
      write_test_file ''
      expect do
        system "./snapdragon -i < #{test_file_path}"
      end .to output("\e[34m金魚草\e[0m:\e[95m1\e[0m > \n").to_stdout_from_any_process
    end

    it 'can show version information' do
      expected_output = (
        "  金魚草 v2.0.1\n" \
        "  Copyright 2020, Rew Howe\n" \
        "  https://github.com/rewhowe/snapdragon\n"
      )
      expect { system './snapdragon -v' } .to output(expected_output).to_stdout_from_any_process
    end

    it 'can separate arguments from options' do
      write_test_file "引数列を 表示する\n"
      expected_output = %({0: "#{test_file_path}", 1: "-d", 2: "-h", 3: "-i", 4: "-l=ja", 5: "-t", 6: "-v", 7: "--"}\n)
      expect do
        system "./snapdragon #{test_file_path} -- -d -h -i -l=ja -t -v --"
      end .to output(expected_output).to_stdout_from_any_process
    end

    it 'cannot accept -i and -t together' do
      expect do
        system './snapdragon -i -t'
      end .to output("Options '-i' and '-t' cannot be used together\n").to_stderr_from_any_process
    end

    it 'shows an error when the input file is not found' do
      expect do
        system './snapdragon does_not_exist.sd'
      end .to output("Input file (does_not_exist.sd) not found\n").to_stderr_from_any_process
    end
  end

  describe 'interactive mode' do
  end
end
