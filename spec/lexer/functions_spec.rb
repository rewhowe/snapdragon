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
          [Token::SCOPE_BEGIN, nil],
            [Token::NO_OP, nil],
          [Token::SCOPE_CLOSE, nil],
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
          [Token::SCOPE_BEGIN, nil],
            [Token::FUNCTION_DEF, 'ふがる'],
              [Token::SCOPE_BEGIN, nil],
                [Token::NO_OP, nil],
              [Token::SCOPE_CLOSE, nil],
          [Token::SCOPE_CLOSE, nil],
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
          [Token::SCOPE_BEGIN, nil],
            [Token::FUNCTION_CALL, 'ほげる'],
          [Token::SCOPE_CLOSE, nil],
      )
    end

    # it 'tokenizes function calls with parameters' do
    # end

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
          [Token::SCOPE_BEGIN, nil],
            [Token::NO_OP, nil],
          [Token::SCOPE_CLOSE, nil],
        [Token::PARAMETER, '「朝ご飯」'],
        [Token::FUNCTION_CALL, '食べる'],
        [Token::PARAMETER, '「昼ご飯」'],
        [Token::FUNCTION_CALL, '食べる'],
      )
    end
  end
end
