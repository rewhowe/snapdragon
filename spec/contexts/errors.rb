RSpec.shared_context 'errors' do
  include_context 'lexer'

  def expect_error(error)
    expect { tokens } .to raise_error error
  end
end
