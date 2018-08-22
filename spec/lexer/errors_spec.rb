require './src/lexer.rb'
require './src/token.rb'
require './spec/contexts/lexer.rb'

RSpec.describe Lexer, 'error handling' do
  include_context 'lexer'

  describe '#tokenize' do
    after :all do
      expect { Lexer.tokenize(@test_file.path) } .to raise_error StandardError
    end

    it 'raises an error when missing tokens' do
      write_test_file [
        '変数は',
      ]
    end

    it 'raises an error when there is too much indent' do
      write_test_file [
        'インデントしすぎるとは',
        '　　行頭の空白は 「多い」',
      ]
    end

    it 'raises an error for unclosed strings in variable declarations' do
      write_test_file [
        '変数はは 「もじれつ',
      ]
    end

    it 'raises an error for unclosed strings parameters' do
      write_test_file [
        'モジレツを 読むとは',
        '　・・・',
        '「もじれつを 読む',
      ]
    end

    it 'raises an error for trailing characters after a bang' do
      write_test_file [
        'ほげるとは',
        '　・・・',
        'ほげる！ あと何かをする',
      ]
    end
  end
end
