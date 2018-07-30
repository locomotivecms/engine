describe 'Jest test suite' do
  it 'should pass successfully' do
    expect(system("cd app/javascript/ && yarn jest")).to be(true)
  end
end
