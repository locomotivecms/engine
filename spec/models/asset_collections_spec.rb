require 'spec_helper'
 
describe AssetCollection do
  
  # it 'should have a valid factory' do
  #   Factory.build(:asset_collection).should be_valid
  # end
  
  describe 'custom fields (beta)' do
    
    before(:each) do
      @collection = Factory.build(:asset_collection, :site => nil)
      @collection.asset_fields.build :label => 'My Description', :_alias => 'description', :kind => 'Text'
      @collection.asset_fields.build :label => 'Active', :kind => 'Boolean'
    end
    
    context 'define core attributes' do
            
      it 'should have an unique name' do
        @collection.asset_fields.first._name.should == "custom_field_1"
        @collection.asset_fields.last._name.should == "custom_field_2"        
      end    
      
      it 'should have an unique alias' do
        @collection.asset_fields.first._alias.should == "description"
        @collection.asset_fields.last._alias.should == "active"
      end  
            
    end
    
    context 'build and save' do
    
      it 'should build asset' do
        asset = @collection.assets.build
        lambda {
          asset.description
          asset.active
        }.should_not raise_error
      end
      
      it 'should assign values to newly built asset' do
        asset = build_asset(@collection)
        asset.description.should == 'Lorem ipsum'
        asset.active.should == true
      end
          
      it 'should save asset' do
        asset = build_asset(@collection)
        asset.save and @collection.reload
        asset = @collection.assets.first
        asset.description.should == 'Lorem ipsum'
        asset.active.should == true
      end
      
      it 'should not modify assets from another collection' do
        asset = build_asset(@collection)
        asset.save and @collection.reload
        new_collection = AssetCollection.new
        lambda { new_collection.assets.build.description }.should raise_error
      end
    
    end
    
    context 'modifying fields' do
      
      before(:each) do
        @asset = build_asset(@collection).save
      end
      
      it 'should add new field' do
        @collection.asset_fields.build :label => 'Active at', :name => 'active_at', :kind => 'Date'
        @collection.upsert(false)
        @collection.reload
        asset = @collection.assets.first
        lambda { asset.active_at }.should_not raise_error
      end
      
      it 'should remove field' do
        @collection.asset_fields.clear
        @collection.upsert(false)    
        @collection.reload    
        asset = @collection.assets.first
        lambda { asset.active }.should raise_error
      end
      
      it 'should rename field label' do
        @collection.asset_fields.first.label = 'Simple description'
        @collection.asset_fields.first._alias = nil
        @collection.upsert(false)
        @collection.reload
        asset = @collection.assets.first
        asset.simple_description.should == 'Lorem ipsum'
      end
      
    end
    
  end
  
  def build_asset(collection)
    collection.assets.build(:name => 'Asset on steroids', :description => 'Lorem ipsum', :active => true)
  end
  
end