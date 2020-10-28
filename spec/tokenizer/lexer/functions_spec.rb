require './src/token'
require './src/tokenizer/lexer'
require './spec/contexts/lexer'

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
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes function redeclaration if the signature is different' do
      mock_reader(
        "ほげるとは\n" \
        "　・・・\n" \
        "フガを ほげるとは\n" \
        "　・・・\n"
      )

      expect(tokens).to contain_exactly(
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, 'フガ', Token::VARIABLE],
        [Token::FUNCTION_DEF, 'ほげる'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes function definitions with ambiguous conjugations if suffixed with bang' do
      mock_reader(
        "商品を かうとは\n" \
        "　・・・\n" \
        "草を かるとは！\n" \
        "　・・・\n"
      )

      expect(tokens).to include(
        [Token::FUNCTION_DEF, 'かる'],
      )
    end

    it 'tokenizes function calls to overridden functions with ambiguous conjugations' do
      mock_reader(
        "商品を かうとは\n" \
        "　・・・\n" \
        "草を かるとは！\n" \
        "　・・・\n" \
        "「芝生」を かって\n"
      )

      expect(tokens).to include(
        [Token::FUNCTION_CALL, 'かる', Token::FUNC_USER],
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
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
        [Token::SCOPE_CLOSE],
      )
    end

    it 'tokenizes function calls' do
      mock_reader(
        "ほげるとは\n" \
        "　・・・\n" \
        "ほげる\n"
      )

      expect(tokens).to include(
        [Token::FUNCTION_CALL, 'ほげる', Token::FUNC_USER]
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
        [Token::FUNCTION_CALL, 'ほげる', Token::FUNC_USER]
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
        [Token::FUNCTION_CALL, 'ほげる', Token::FUNC_USER],
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
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
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
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
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, '「朝ご飯」', Token::VAL_STR],
        [Token::FUNCTION_CALL, '食べる', Token::FUNC_USER],
        [Token::PARAMETER, '「昼ご飯」', Token::VAL_STR],
        [Token::FUNCTION_CALL, '食べる', Token::FUNC_USER],
      )
    end

    it 'tokenizes function calls with similarly-named parameters' do
      mock_reader(
        "いそいは 1\n" \
        "ホゲで いそぐとは\n" \
        "　・・・\n" \
        "いそいで いそいで\n"
      )
      expect(tokens).to contain_exactly(
        [Token::ASSIGNMENT, 'いそい', Token::VARIABLE], [Token::RVALUE, '1', Token::VAL_NUM],
        [Token::PARAMETER, 'ホゲ', Token::VARIABLE],
        [Token::FUNCTION_DEF, 'いそぐ'],
        [Token::SCOPE_BEGIN],
        [Token::NO_OP],
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, 'いそい', Token::VARIABLE],
        [Token::FUNCTION_CALL, 'いそぐ', Token::FUNC_USER],
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
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, '「野菜」', Token::VAL_STR],
        [Token::FUNCTION_CALL, '食べる', Token::FUNC_USER],
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
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, '「野菜」', Token::VAL_STR],
        [Token::FUNCTION_CALL, '食べる', Token::FUNC_USER],
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
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, '「本当に野菜」', Token::VAL_STR],
        [Token::FUNCTION_CALL, '食べる', Token::FUNC_USER],
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
        [Token::PARAMETER, '無', Token::VAL_NULL], [Token::RETURN],
        [Token::SCOPE_CLOSE],
        [Token::PARAMETER, '「Ａ」', Token::VAL_STR],
        [Token::PARAMETER, '「Ｂ」', Token::VAL_STR],
        [Token::FUNCTION_CALL, 'ほげる', Token::FUNC_USER],
      )
    end
  end
end
