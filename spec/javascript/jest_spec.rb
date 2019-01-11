describe 'Jest test suite' do
  it 'should pass successfully' do
    expect(system('yarn test')).to be(true)
  end
end
