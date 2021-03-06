require './src/token'
require './src/tokenizer/built_ins'
require './src/interpreter/processor'
require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'loops' do
  include_context 'processor'

  describe '#execute' do
    # NOTE: Only tests if a single iteration is successful. Otherwise we're
    # solving the halting problem.
    it 'can (potentially) loop forever' do
      mock_lexer(
        Token.new(Token::LOOP, '繰り返す'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::BREAK),
        Token.new(Token::SCOPE_CLOSE),
      )
      expect { execute } .to_not raise_error
    end

    it 'can loop over string variables' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '「あいうえお」', sub_type: Token::VAL_STR),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::LOOP_ITERATOR),
        Token.new(Token::LOOP),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'それ', particle: 'を', sub_type: Token::VAR_SORE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PRINT, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::SCOPE_CLOSE),
      )
      expect { execute } .to output('あいうえお').to_stdout
      expect(sore).to eq 'お'
    end

    it 'can loop over string primitives' do
      mock_lexer(
        Token.new(Token::PARAMETER, '「あいうえお」', particle: 'に', sub_type: Token::VAL_STR),
        Token.new(Token::LOOP_ITERATOR),
        Token.new(Token::LOOP),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'それ', particle: 'を', sub_type: Token::VAR_SORE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PRINT, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::SCOPE_CLOSE),
      )
      expect { execute } .to output('あいうえお').to_stdout
      expect(sore).to eq 'お'
    end

    it 'can loop over arrays' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::ARRAY_BEGIN),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM), Token.new(Token::COMMA),
        Token.new(Token::RVALUE, '3', sub_type: Token::VAL_NUM),
        Token.new(Token::ARRAY_CLOSE),
        Token.new(Token::PARAMETER, 'フガ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::LOOP_ITERATOR),
        Token.new(Token::LOOP),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'それ', particle: 'を', sub_type: Token::VAR_SORE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(variable('ホゲ')).to eq 6
    end

    it 'can loop over a range of number primitives' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '3', particle: 'まで', sub_type: Token::VAL_NUM),
        Token.new(Token::LOOP),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'それ', particle: 'を', sub_type: Token::VAR_SORE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(variable('ホゲ')).to eq 6
    end

    it 'can loop over a range of numeric variables' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '3', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'から', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'フガ', particle: 'まで', sub_type: Token::VARIABLE),
        Token.new(Token::LOOP),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'それ', particle: 'を', sub_type: Token::VAR_SORE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(variable('ホゲ')).to eq 6
    end

    it 'can loop over floats (cast to integers)' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '3.14', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '12.34', particle: 'まで', sub_type: Token::VAL_NUM),
        Token.new(Token::LOOP),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'それ', particle: 'を', sub_type: Token::VAR_SORE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::ADD, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'それ', sub_type: Token::VAR_SORE),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(variable('ホゲ')).to eq 75 # 3 + 4 + ... + 11 + 12
    end

    it 'can loop over a range of numbers in reverse order' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '配列', sub_type: Token::VAL_ARRAY),
        Token.new(Token::PARAMETER, '10', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '1', particle: 'まで', sub_type: Token::VAL_NUM),
        Token.new(Token::LOOP),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'ホゲ', particle: 'に', sub_type: Token::VARIABLE),
        Token.new(Token::PARAMETER, 'それ', particle: 'を', sub_type: Token::VAR_SORE),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::PUSH, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::SCOPE_CLOSE),
      )
      execute
      expect(variable('ホゲ')).to eq sd_array [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    end

    it 'can skip iterations with NEXT' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '10', particle: 'まで', sub_type: Token::VAL_NUM),
        Token.new(Token::LOOP),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::NEXT),
        Token.new(Token::PARAMETER, '「エラー」', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::THROW, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::SCOPE_CLOSE),
      )
      expect { execute } .to_not raise_error
      expect(sore).to eq 10
    end

    it 'can stop iteration with BREAK' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '0', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '1', particle: 'から', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '10', particle: 'まで', sub_type: Token::VAL_NUM),
        Token.new(Token::LOOP),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::BREAK),
        Token.new(Token::PARAMETER, '「エラー」', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::THROW, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::SCOPE_CLOSE),
      )
      expect { execute } .to_not raise_error
      expect(sore).to eq 1
    end

    it 'can process variables defined in a loop, outside of said loop' do
      mock_lexer(
        Token.new(Token::LOOP),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::BREAK),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::ASSIGNMENT, 'フガ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, 'ホゲ', sub_type: Token::VARIABLE),
      )
      expect { execute } .to_not raise_error
      expect(variable('フガ')).to eq 1
    end
  end
end
