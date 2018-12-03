# encoding: utf-8

describe Locomotive::Role do

  describe 'validation' do
    it 'store pages in array' do
      role = create(:role, role_pages_str: '1,2,3,4')
      expect(role.role_pages).to eq(['1','2','3','4'])
    end
  end

end