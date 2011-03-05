require 'spec_helper'

describe AssetCollection do

  it 'should have a valid factory' do
    Factory.build(:asset_collection).should be_valid
  end

  describe 'custom fields (beta)' do

    before(:each) do
      Site.any_instance.stubs(:create_default_pages!).returns(true)
      site = Factory.build(:site)
      Site.stubs(:find).returns(site)
      @collection = Factory.build(:asset_collection, :site => site)
      @collection.asset_custom_fields.build :label => 'My Description', :_alias => 'description', :kind => 'Text'
      @collection.asset_custom_fields.build :label => 'Active', :kind => 'Boolean'
      # AssetCollection.logger = Logger.new($stdout)
      # AssetCollection.db.connection.instance_variable_set(:@logger, Logger.new($stdout))
    end

    context 'unit' do

      before(:each) do
        @field = CustomFields::Field.new(:kind => 'String')
      end

      it 'should tell if it is a String' do
        @field.string?.should be_true
      end

      it 'should tell if it is a Text' do
        @field.kind = 'Text'
        @field.text?.should be_true
      end

    end

    context 'validation' do

      %w{label kind}.each do |key|
        it "should validate presence of #{key}" do
          field = @collection.asset_custom_fields.build({ :label => 'Shortcut', :kind => 'String' }.merge(key.to_sym => nil))
          field.should_not be_valid
          field.errors[key.to_sym].should == ["can't be blank"]
        end
      end

      it 'should not have unique label' do
        field = @collection.asset_custom_fields.build :label => 'Active', :kind => 'Boolean'
        field.should_not be_valid
        field.errors[:label].should == ["is already taken"]
      end

      it 'should invalidate parent if custom field is not valid' do
        field = @collection.asset_custom_fields.build
        @collection.should_not be_valid
        @collection.asset_custom_fields.last.errors[:label].should == ["can't be blank"]
      end

    end

    context 'define core attributes' do

      it 'should have an unique name' do
        @collection.asset_custom_fields.first._name.should == "custom_field_1"
        @collection.asset_custom_fields.last._name.should == "custom_field_2"
      end

      it 'should have an unique alias' do
        @collection.asset_custom_fields.first.safe_alias.should == "description"
        @collection.asset_custom_fields.last.safe_alias.should == "active"
      end

    end

    context 'build and save' do

      it 'should build asset' do
        asset = @collection.assets.build
        lambda {
          asset.description
          asset.active
          asset.custom_fields.size.should == 2
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
        @collection.asset_custom_fields.build :label => 'Active at', :name => 'active_at', :kind => 'Date'
        @collection.upsert(:validate => false)
        @collection.invalidate_asset_klass
        @collection.reload
        asset = @collection.assets.first
        lambda { asset.active_at }.should_not raise_error
      end

      it 'should remove field' do
        @collection.asset_custom_fields.clear
        @collection.upsert(:validate => false)
        @collection.invalidate_asset_klass
        @collection.reload
        asset = @collection.assets.first
        lambda { asset.active_at }.should raise_error
      end

      it 'should rename field label' do
        @collection.asset_custom_fields.first.label = 'Simple description'
        @collection.asset_custom_fields.first._alias = nil
        @collection.upsert(:validate => false)

        @collection.invalidate_asset_klass
        @collection.reload

        asset = @collection.assets.first
        asset.simple_description.should == 'Lorem ipsum'
      end

    end

    context 'managing from hash' do

      it 'adds new field' do
        @collection.asset_custom_fields.clear
        field = @collection.asset_custom_fields.build :label => 'Title'
        @collection.asset_custom_fields_attributes = { 0 => { :id => field.id.to_s, 'label' => 'A title', 'kind' => 'String' }, 1 => { 'label' => 'Tagline', 'kind' => 'String' } }
        @collection.asset_custom_fields.size.should == 2
        @collection.asset_custom_fields.first.label.should == 'A title'
        @collection.asset_custom_fields.last.label.should == 'Tagline'
      end

      it 'updates/removes fields' do
        field = @collection.asset_custom_fields.build :label => 'Title', :kind => 'String'
        @collection.save; @collection = AssetCollection.find(@collection.id)
        @collection.update_attributes(:asset_custom_fields_attributes => {
          '0' => { 'id' => lookup_field_id(0), 'label' => 'My Description', 'kind' => 'Text', '_destroy' => '1' },
          '1' => { 'id' => lookup_field_id(1), 'label' => 'Active', 'kind' => 'Boolean', '_destroy' => '1' },
          '2' => { 'id' => lookup_field_id(2), 'label' => 'My Title !', 'kind' => 'String' },
          'new_record' => { 'label' => 'Published at', 'kind' => 'String' }
        })
        @collection = AssetCollection.find(@collection.id)
        @collection.asset_custom_fields.size.should == 2
        @collection.asset_custom_fields.first.label.should == 'My Title !'
      end

    end

  end

  def build_asset(collection)
    collection.assets.build(:name => 'Asset on steroids', :description => 'Lorem ipsum', :active => true)
  end

  def lookup_field_id(index)
    @collection.asset_custom_fields.all[index].id.to_s
  end

end
