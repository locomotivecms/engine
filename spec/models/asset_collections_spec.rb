require 'spec_helper'
 
describe AssetCollection do
  
  it 'should have a valid factory' do
    Factory.build(:asset_collection).should be_valid
  end
  
  describe 'custom fields (beta)' do
    
    before(:each) do
      @collection = Factory.build(:asset_collection)
      @collection.asset_fields.build :label => 'My Description', :_alias => 'description', :kind => 'Text'
      @collection.asset_fields.build :label => 'Active', :kind => 'Boolean'
    end
    
    context 'define attributes' do
            
      # it 'should have an unique name' do
      #   @collection.asset_fields.first._name.should == "custom_field_1"
      #   @collection.asset_fields.last._name.should == "custom_field_2"        
      # end    
      
      it 'should have an unique alias' do
        @collection.save
        @collection.asset_fields.first._alias.should == "description"
        @collection.asset_fields.last._alias.should == "active"
      end  
      
      # 
      # it 'should define a position according to siblings'   
      
    end
    
    # context 'build and save' do
    # 
    #   it 'should build asset' do
    #     asset = @collection.assets.build
    #     lambda {
    #       asset.description
    #       asset.active
    #     }.should_not raise_error
    #   end
    #   
    #   it 'should assign values to newly built asset' do
    #     asset = build_asset(@collection)
    #     asset.description.should == 'Lorem ipsum'
    #     asset.active.should == true
    #   end
    # 
    #   it 'should save asset' do
    #     asset = build_asset(@collection)
    #     asset.save and @collection.reload
    #     asset = @collection.assets.first
    #     asset.description.should == 'Lorem ipsum'
    #     asset.active.should == true
    #   end
    #   
    #   it 'should not modify assets from another collection' do
    #     asset = build_asset(@collection)
    #     asset.save and @collection.reload
    #     new_collection = AssetCollection.new
    #     lambda { new_collection.assets.build.description }.should raise_error
    #   end
    # 
    # end
    # 
    context 'modifying fields' do
      
      # before(:each) do
      #   @asset = build_asset(@collection).save
      # end
      # 
      # it 'should add new field' do
      #   @collection.asset_fields.build :label => 'Active at', :name => 'active_at', :kind => 'Date'
      #   @collection.save
      #   
      #   # puts "association = #{@collection.send(:associations)['assets'].options.inspect}"
      #   
      #   # @collection = AssetCollection.first
      #   # @collection.flush_cache(:asset_fields)
      #   @collection.reload
      #   # puts "# fields #{@collection.asset_fields.size.inspect}"  
      #   # puts "============================"
      #   # puts "@collection asset fields ==> #{@collection.asset_fields.inspect}"
      #   asset = @collection.assets.first
      #   lambda { asset.active_at }.should_not raise_error
      # end
      
      # it 'should remove field' do
      #   @collection.asset_fields.delete_all :name => 'active'
      #   @collection.save
      #   lambda { asset.active }.should raise_error
      # end
      # 
      # it 'should be able to change field name'
      
    end
    
  end
  
  def build_asset(collection)
    collection.assets.build(:name => 'Asset on steroids', :description => 'Lorem ipsum', :active => true)
  end
  
end