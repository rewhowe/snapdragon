require './src/token'
require './src/interpreter/processor'
require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'try' do
  include_context 'processor'

  describe '#execute' do
    it 'catches errors inside try' do
      mock_lexer(
        Token.new(Token::TRY),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, '1', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::PARAMETER, '0', particle: 'を', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::DIVIDE, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::SCOPE_CLOSE),
      )
      expect { execute } .to_not raise_error
      expect(variable('例外')).to be_truthy
    end

    it 'catches calls to throw inside try' do
      mock_lexer(
        Token.new(Token::TRY),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'hoge', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::THROW, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::SCOPE_CLOSE),
      )
      allow($stderr).to receive(:write) # suppress stderr
      expect { execute } .to_not raise_error
      expect(variable('例外')).to eq 'hoge'
    end

    it 'clears the error if no error occurs in try' do
      mock_lexer(
        Token.new(Token::TRY),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::PARAMETER, 'hoge', particle: 'を', sub_type: Token::VAL_STR),
        Token.new(Token::FUNCTION_CALL, Tokenizer::BuiltIns::THROW, sub_type: Token::FUNC_BUILT_IN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::TRY),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::SCOPE_CLOSE),
      )
      allow($stderr).to receive(:write) # suppress stderr
      expect { execute } .to_not raise_error
      expect(variable('例外')).to eq nil
    end
  end
end
