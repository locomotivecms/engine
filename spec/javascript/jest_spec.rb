describe 'Jest test suite' do
  it 'should pass successfully' do
    expect(system("cd app/javascript/ && jest")).to be(true)
  end
end
