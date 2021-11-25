require './spec/contexts/test_file'
require 'readline'

RSpec.describe 'Snapdragon', 'command line execution' do
  include_context 'test_file'

  describe 'options' do
    ##
    # Functionally equivalent to -h and --help options
    it 'shows a usage message when there are no arguments' do
      expect(`./snapdragon`).to include 'Usage:'
    end

    it 'can show various levels of debug messages' do
      write_test_file "「こんにちは、世界！」を ポイ捨てる\n"

      # debug off
      expect { system "./snapdragon #{test_file_path}" } .to_not output.to_stdout_from_any_process

      {
        1 => { output: 'TRY:' },
        2 => { output: 'RECEIVE:', not_output: 'TRY:' },
        3 => { output: 'こんにちは、世界！', not_output: 'RECEIVE:' },
      }.each do |level, test|
        output = `./snapdragon -d#{level} #{test_file_path}`
        expect(output).to include test[:output]
        expect(output).to_not include test[:not_output] if test[:not_output]
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

      output = `./snapdragon -t #{test_file_path}`
      expect(colourless(output)).to include 'parameter 「こんにちは、世界！￥ｎ」 val_str'
      expect(colourless(output)).to include 'function_call PRINT func_built_in'
    end

    it 'can enter interactive mode' do
      write_test_file ''
      output = `./snapdragon -i < #{test_file_path}`
      expect(colourless(output)).to start_with '金魚草:1 >'
    end

    it 'can show version information' do
      output = `./snapdragon -v`
      expect(output).to eq(
        "  金魚草 v2.0.1\n" \
        "  Copyright 2020, Rew Howe\n" \
        "  https://github.com/rewhowe/snapdragon\n"
      )
    end

    it 'can separate arguments from options' do
      write_test_file "引数列を 表示する\n"
      expected_output = %({0: "#{test_file_path}", 1: "-d", 2: "-h", 3: "-i", 4: "-l=ja", 5: "-t", 6: "-v", 7: "--"}\n)
      output = `./snapdragon #{test_file_path} -- -d -h -i -l=ja -t -v --`
      expect(output).to eq expected_output
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

  ##
  # Doesn't quite work as usual when run through rspec. Output appears alongside
  # the input prompts instead of as separate output.
  describe 'interactive mode' do
    it 'can execute single-line commands' do
      write_test_file "「ほげ￥ｎ」と 言う\n"
      expect do
        system("./snapdragon -i < #{test_file_path}")
      end .to output(/ほげ$/).to_stdout_from_any_process
    end

    it 'can execute multi-line commands' do
      write_test_file(
        "ほげるとは￥\n" \
        "　「ほげ￥ｎ」と 言う\n" \
        "\n" \
        "ほげる\n"
      )
      expect do
        system("./snapdragon -i < #{test_file_path}")
      end .to output(/ほげ$/).to_stdout_from_any_process
    end

    it 'can continue after an error' do
      write_test_file(
        "ホゲは 「ふが」\n" \
        "1を 0で 割る\n" \
        "ホゲを 言う\n"
      )
      output = `./snapdragon -i < #{test_file_path}`
      expect(output).to include 'Division by zero'
      expect(output).to end_with "ふが\n"
    end

    it 'can re-define functions even after failed function definitions' do
      write_test_file(
        "ほげるとは￥\n" \
        "　not valid snapdragon code\n" \
        "\n" \
        "ほげる\n" \
        "ほげるとは￥\n" \
        "　「ふが」と 言う\n" \
        "\n" \
        "ほげる\n"
      )
      output = `./snapdragon -i < #{test_file_path}`
      expect(output).to include 'Unexpected input'
      expect(output).to include 'Function does not exist'
      expect(output).to end_with "ふが\n"
    end

    it 'can re-define functions even after defined in failed blocks' do
      write_test_file(
        "もし 1が 1と 同じ ならば￥\n" \
        "　ほげるとは\n" \
        "　　「ふが」と 言う\n" \
        "　not valid snapdragon code\n" \
        "\n" \
        "ほげる\n" \
        "ほげるとは￥\n" \
        "　「ぴよ」と 言う\n" \
        "\n" \
        "ほげる\n"
      )
      output = `./snapdragon -i < #{test_file_path}`
      expect(output).to include 'Unexpected input'
      expect(output).to include 'Function does not exist'
      expect(output).to end_with "ぴよ\n"
    end
  end

  private

  def colourless(string)
    string.gsub(/\e\[\d+m/, '')
  end
end
