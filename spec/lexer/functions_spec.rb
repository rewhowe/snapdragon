require './src/lexer.rb'
require './src/token.rb'
require './spec/contexts/lexer.rb'

RSpec.describe Lexer, 'functions' do
  include_context 'lexer'

  describe '#tokenize' do
    it 'tokenizes function declarations' do
      write_test_file [
        'ほげるとは',
        '　・・・',
      ]

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes nested function declarations' do
      write_test_file [
        'ほげるとは',
        '　ふがるとは',
        '　　・・・'
      ]

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::FUNCTION_DEF, 'ふがる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes function calls' do
      write_test_file [
        'ほげるとは',
        '　・・・',
        'ほげる',
      ]

      expect(tokens).to include(
        [Token::FUNCTION_CALL, 'ほげる']
      )
    end

    it 'tokenizes calls to parent scope functions' do
      write_test_file [
        'ほげるとは',
        '　・・・',
        'ふがるとは',
        '　ほげる',
      ]

      expect(tokens).to include(
        [Token::FUNCTION_CALL, 'ほげる']
      )
    end

    it 'tokenizes function calls to self' do
      write_test_file [
        'ほげるとは',
        '　ほげる',
      ]

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::FUNCTION_CALL, 'ほげる'],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes function calls with parameters' do
      write_test_file [
        'トモダチと ドコカへ ナニカを ノリモノで 一緒に持っていくとは',
        '　・・・',
      ]

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, 'トモダチ'],
        [Token::PARAMETER, 'ドコカ'],
        [Token::PARAMETER, 'ナニカ'],
        [Token::PARAMETER, 'ノリモノ'],
        [Token::FUNCTION_DEF, '一緒に持っていく'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes conjugated function calls' do
      write_test_file [
        'タベモノを 食べるとは',
        '　・・・',
        '「朝ご飯」を 食べた',
        '「昼ご飯」を 食べて',
      ]

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, 'タベモノ'],
        [Token::FUNCTION_DEF, '食べる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, '「朝ご飯」'],
        [Token::FUNCTION_CALL, '食べる'],
        [Token::PARAMETER, '「昼ご飯」'],
        [Token::FUNCTION_CALL, '食べる'],
      )
    end

    it 'tokenizes function calls with questions' do
      # TODO
    end

    it 'tokenizes function calls with bangs' do
      # TODO
    end

    it 'tokenizes function calls with bang-questions' do
      # TODO
    end
  end
end
