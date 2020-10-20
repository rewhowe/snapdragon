require './src/tokenizer/reader.rb'
require './src/tokenizer/errors.rb'

require './spec/contexts/test_file.rb'

include Tokenizer

RSpec.describe Reader, 'file reading in chunks' do
  include_context 'test_file'

  def init_reader_with_contents(contents)
    write_test_file contents
    @reader = Reader.new filename: test_file_path
  end

  describe '#next_chunk' do
    it 'can read and consume chunks' do
      init_reader_with_contents 'hello world'
      expect(@reader.next_chunk).to eq 'hello'
      expect(@reader.next_chunk).to eq ' '
    end

    it 'can read chunks without consuming them' do
      init_reader_with_contents 'hello world'
      expect(@reader.next_chunk(consume?: false)).to eq 'hello'
      expect(@reader.next_chunk(consume?: false)).to eq 'hello'
    end

    it 'reads a whole string as one chunk' do
      init_reader_with_contents '「あ い う え お」'
      expect(@reader.next_chunk).to eq '「あ い う え お」'
    end

    it 'discards entire block comments' do
      init_reader_with_contents '※あ い う え お※'
      expect(@reader.next_chunk).to be_nil
    end

    it 'reads a whole string as one chunk even if it contains a block comment' do
      init_reader_with_contents '「※あ い う え お※」'
      expect(@reader.next_chunk).to eq '「※あ い う え お※」'
    end

    it 'reads a whole string as one chunk even if it contains a newline' do
      init_reader_with_contents "「あ\nい\nう\nえ\nお」"
      expect(@reader.next_chunk).to eq "「あ\nい\nう\nえ\nお」"
    end

    it 'discards entire block comments as one chunk even if it contains a string' do
      init_reader_with_contents '※「あ い う え お」※'
      expect(@reader.next_chunk).to be_nil
    end

    it 'discards entire block comments as one chunk even if it contains a newline' do
      init_reader_with_contents '※あ\nい\nう\nえ\nお※'
      expect(@reader.next_chunk).to be_nil
    end

    it 'reads until EOL when it sees an inline comment' do
      init_reader_with_contents "（あ い う え お\n"
      expect(@reader.next_chunk).to eq "\n"
    end

    it 'raises an error on an unclosed string' do
      init_reader_with_contents '「あ'
      expect { @reader.next_chunk } .to raise_error Errors::UnclosedString
    end

    it 'raises an error on an unclosed block comment' do
      init_reader_with_contents '※あ'
      expect { @reader.next_chunk } .to raise_error Errors::UnclosedBlockComment
    end

    it 'does not raise an error when discarding to EOL and EOF is found' do
      init_reader_with_contents '（あ'
      expect { @reader.next_chunk } .to_not raise_error
    end

    it 'does not raise an error when reading to next non-whitespace and EOF is found' do
      init_reader_with_contents ' '
      expect { @reader.next_chunk } .to_not raise_error
    end
  end

  describe '#peek_next_chunk' do
    it 'returns the next chunk without consuming it' do
      init_reader_with_contents 'hello world'
      @reader.next_chunk # hello
      expect(@reader.peek_next_chunk).to eq 'world'
      expect(@reader.next_chunk).to eq ' '
      expect(@reader.next_chunk).to eq 'world'
    end

    it 'returns the next non-whitespace chunk' do
      init_reader_with_contents "hello 　 world"
      @reader.next_chunk # hello
      expect(@reader.peek_next_chunk).to eq 'world'
    end

    it 'can return the next whitespace chunk' do
      init_reader_with_contents "hello 　 world"
      @reader.next_chunk # hello
      expect(@reader.peek_next_chunk(skip_whitespace?: false)).to eq ' 　 '
    end

    it 'returns an empty string when all remaining whitespace is skipped' do
      init_reader_with_contents "hello   "
      @reader.next_chunk # hello
      expect(@reader.peek_next_chunk).to eq ''
    end
  end

  describe '#finished?' do
    it 'finishes when it can no longer read' do
      init_reader_with_contents "hello world"
      3.times { @reader.next_chunk }
      expect(@reader.finished?).to be_truthy
    end
  end
end
