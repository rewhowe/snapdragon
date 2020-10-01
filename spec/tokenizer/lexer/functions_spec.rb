require './src/tokenizer/lexer.rb'
require './src/tokenizer/token.rb'
require './spec/contexts/lexer.rb'

include Tokenizer

RSpec.describe Lexer, 'functions' do
  include_context 'lexer'

  describe '#next_token' do
    it 'tokenizes function declarations' do
      mock_reader(
        "ほげるとは\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes nested function declarations' do
      mock_reader(
        "ほげるとは\n" \
        "　ふがるとは\n" \
        "　　・・・\n"
      )

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::FUNCTION_DEF, 'ふがる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE], [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes function calls' do
      mock_reader(
        "ほげるとは\n" \
        "　・・・\n" \
        "ほげる\n"
      )

      expect(tokens).to include(
        [Token::FUNCTION_CALL, 'ほげる']
      )
    end

    it 'tokenizes calls to parent scope functions' do
      mock_reader(
        "ほげるとは\n" \
        "　・・・\n" \
        "ふがるとは\n" \
        "　ほげる\n"
      )

      expect(tokens).to include(
        [Token::FUNCTION_CALL, 'ほげる']
      )
    end

    it 'tokenizes function calls to self' do
      mock_reader(
        "ほげるとは\n" \
        "　ほげる\n"
      )

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::FUNCTION_CALL, 'ほげる'],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes function calls with parameters' do
      mock_reader(
        "トモダチと ドコカへ ナニカを ノリモノで 一緒に持っていくとは\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, 'トモダチ', Token::VARIABLE],
        [Token::PARAMETER, 'ドコカ', Token::VARIABLE],
        [Token::PARAMETER, 'ナニカ', Token::VARIABLE],
        [Token::PARAMETER, 'ノリモノ', Token::VARIABLE],
        [Token::FUNCTION_DEF, '一緒に持っていく'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes conjugated function calls' do
      mock_reader(
        "タベモノを 食べるとは\n" \
        "　・・・\n" \
        "「朝ご飯」を 食べた\n" \
        "「昼ご飯」を 食べて\n" \
      )

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, 'タベモノ', Token::VARIABLE],
        [Token::FUNCTION_DEF, '食べる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, '「朝ご飯」', Token::VAR_STR],
        [Token::FUNCTION_CALL, '食べる'],
        [Token::PARAMETER, '「昼ご飯」', Token::VAR_STR],
        [Token::FUNCTION_CALL, '食べる'],
      )
    end

    it 'tokenizes function calls with questions' do
      mock_reader(
        "タベモノを 食べるとは\n" \
        "　・・・\n" \
        "「野菜」を 食べた？\n"
      )

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, 'タベモノ', Token::VARIABLE],
        [Token::FUNCTION_DEF, '食べる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, '「野菜」', Token::VAR_STR],
        [Token::FUNCTION_CALL, '食べる'],
        [Token::QUESTION],
      )
    end

    it 'tokenizes function calls with bangs' do
      mock_reader(
        "タベモノを 食べるとは\n" \
        "　・・・\n" \
        "「野菜」を 食べて！\n"
      )

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, 'タベモノ', Token::VARIABLE],
        [Token::FUNCTION_DEF, '食べる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, '「野菜」', Token::VAR_STR],
        [Token::FUNCTION_CALL, '食べる'],
        [Token::BANG],
      )
    end

    it 'tokenizes function calls with bang-questions' do
      mock_reader(
        "タベモノを 食べるとは\n" \
        "　・・・\n" \
        "「本当に野菜」を 食べた！？\n"
      )

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, 'タベモノ', Token::VARIABLE],
        [Token::FUNCTION_DEF, '食べる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, '「本当に野菜」', Token::VAR_STR],
        [Token::FUNCTION_CALL, '食べる'],
        [Token::BANG],
        [Token::QUESTION],
      )
    end

    it 'tokenizes function calls regardless of parameter order' do
      mock_reader(
        "Ａと Ｂを ほげるとは\n" \
        "　・・・\n" \
        "「Ａ」を 「Ｂ」と ほげる\n"
      )

      expect(tokens).to contain_exactly(
        [Token::PARAMETER, 'Ａ', Token::VARIABLE],
        [Token::PARAMETER, 'Ｂ', Token::VARIABLE],
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, '「Ａ」', Token::VAR_STR],
        [Token::PARAMETER, '「Ｂ」', Token::VAR_STR],
        [Token::FUNCTION_CALL, 'ほげる'],
      )
    end
  end
end
