require 'spec_helper'

describe 'Httparty patches' do

  describe 'Crack patch' do

    context '#parsing json' do
  
      it 'fixes an issue about json input beginning by a variable declaration' do
        lambda {
          Crack::JSON.parse('var json = { "foo": 42 };')
        }.should_not raise_error
      end
  
    end
  
  end
  
end