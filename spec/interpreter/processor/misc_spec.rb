require './src/token'
require './src/interpreter/processor'
require './spec/contexts/processor'

RSpec.describe Interpreter::Processor, 'misc' do
  include_context 'processor'

  describe '#execute' do
    it 'does not do anything in particular for no-op' do
      mock_lexer(
        Token.new(Token::NO_OP),
      )
      expect { execute } .to_not raise_error
    end

    it 'can process a debug command' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::FUNCTION_DEF, 'ほげる'),
        Token.new(Token::SCOPE_BEGIN),
        Token.new(Token::DEBUG),
        Token.new(Token::PARAMETER, '無', particle: 'を', sub_type: Token::VAL_NULL), Token.new(Token::RETURN),
        Token.new(Token::SCOPE_CLOSE),
        Token.new(Token::FUNCTION_CALL, 'ほげる', sub_type: Token::FUNC_USER),
      )
      expect { execute } .to output(
        "\e[94m" \
         "Variables:\n" \
        "・引数列 => {}\n" \
        "・ホゲ => 1\n" \
        "Functions:\n" \
        "・ほげる\n" \
        "\n" \
        "Variables:\n" \
        "\n" \
        "Functions:\n" \
        "\n" \
        "\n" \
        "それ: 1\n" \
        "あれ: null\e[0m\n"
      ).to_stdout
    end

    it 'stops execution on debug bang' do
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '1', sub_type: Token::VAL_NUM),
        Token.new(Token::DEBUG),
        Token.new(Token::BANG),
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::RVALUE, '2', sub_type: Token::VAL_NUM),
      )
      allow($stdout).to receive(:write) # suppress stdout
      expect { execute } .to raise_error SystemExit
      expect(variable('ホゲ')).to eq 1
    end

    it 'can receive command-line arguments' do
      set_options argv: ['hoge']
      mock_lexer(
        Token.new(Token::ASSIGNMENT, 'ホゲ', sub_type: Token::VARIABLE),
        Token.new(Token::POSSESSIVE, '引数列', sub_type: Token::VARIABLE),
        Token.new(Token::PROPERTY, '先頭', sub_type: Token::PROP_FIRST),
      )
      execute
      expect(variable('ホゲ')).to eq 'hoge'
    end
  end
end
