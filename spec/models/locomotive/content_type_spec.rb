require 'spec_helper'

describe Locomotive::ContentType do

  before(:each) do
    Locomotive::Site.any_instance.stubs(:create_default_pages!).returns(true)
  end

  context 'when validating' do

    it 'should have a valid factory' do
      content_type = FactoryGirl.build(:content_type)
      content_type.entries_custom_fields.build :label => 'anything', :type => 'String'
      content_type.should be_valid
    end

    # Validations ##

    %w{site name}.each do |field|
      it "requires the presence of #{field}" do
        content_type = FactoryGirl.build(:content_type, field.to_sym => nil)
        content_type.should_not be_valid
        content_type.errors[field.to_sym].should == ["can't be blank"]
      end
    end

    it 'requires the presence of slug' do
      content_type = FactoryGirl.build(:content_type, :name => nil, :slug => nil)
      content_type.should_not be_valid
      content_type.errors[:slug].should == ["can't be blank"]
    end

    it 'is not valid if slug is not unique' do
      content_type = FactoryGirl.build(:content_type)
      content_type.entries_custom_fields.build :label => 'anything', :type => 'String'
      content_type.save
      (content_type = FactoryGirl.build(:content_type, :site => content_type.site)).should_not be_valid
      content_type.errors[:slug].should == ["is already taken"]
    end

    it 'is not valid if there is not at least one field' do
      content_type = FactoryGirl.build(:content_type)
      content_type.should_not be_valid
      content_type.errors[:entries_custom_fields].should == ["is too small (minimum element number is 1)"]
    end

    %w(created_at updated_at).each do |name|
      it "does not allow #{name} as name" do
        content_type = FactoryGirl.build(:content_type)
        field = content_type.entries_custom_fields.build :label => 'anything', :type => 'String', :name => name
        field.valid?.should be_false
        field.errors[:name].should == ['is reserved']
      end
    end

  end

  context '#ordered_entries' do

    before(:each) do
      @content_type = FactoryGirl.build(:content_type, :order_by => 'created_at')
      @content_1 = stub('content_1', :name => 'Did', :_position_in_list => 2)
      @content_2 = stub('content_2', :name => 'Sacha', :_position_in_list => 1)
      @content_type.stubs(:entries).returns([@content_1, @content_2])
    end

    it 'orders with the ASC direction by default' do
      @content_type.asc_order?.should == true
    end

    it 'has a getter for manual order' do
      @content_type.order_manually?.should == false
      @content_type.order_by = '_position_in_list'
      @content_type.order_manually?.should == true
    end

    it 'returns a list of entries ordered manually' do
      @content_type.order_by = '_position_in_list'
      @content_type.ordered_entries.collect(&:name).should == %w(Sacha Did)
    end

    it 'returns a list of entries ordered by a column specified by order_by (ASC)' do
      @content_type.order_by = 'name'
      @content_type.ordered_entries.collect(&:name).should == %w(Did Sacha)
    end

    it 'returns a list of entries ordered by a column specified by order_by (DESC)' do
      @content_type.order_by = 'name'
      @content_type.order_direction = 'desc'
      @content_type.ordered_entries.collect(&:name).should == %w(Sacha Did)
    end

    it 'returns a list of entries ordered by a Date column when first instance is missing the value' do
      @content_type = FactoryGirl.build(:content_type, :order_by => 'created_at')
      @content_type.content_custom_fields.build :label => 'Active at', :name => 'active_at', :type => 'Date'
      e = Date.parse('01/01/2001')
      l = Date.parse('02/02/2002')
      [nil,e,l].each { |d| @content_type.entries << @content_type.content_klass.new(:active_at => d) }
      @content_type.order_by = 'active_at'
      @content_type.order_direction = 'asc'
      lambda { @content_type.ordered_entries }.should_not raise_error(ArgumentError)
      @content_type.ordered_entries.map(&:active_at).should == [nil,e,l]
      @content_type.order_direction = 'desc'
      @content_type.ordered_entries.map(&:active_at).should == [l,e,nil]
    end

  end

  describe 'custom fields' do

    before(:each) do
      site = FactoryGirl.build(:site)
      Locomotive::Site.stubs(:find).returns(site)
      @content_type = FactoryGirl.build(:content_type, :site => site, :highlighted_field_name => 'custom_field_1')
      @content_type.entries_custom_fields.build :label => 'My Description', :name => 'description', :type => 'text'
      @content_type.entries_custom_fields.build :label => 'Active', :type => 'boolean'
      # Locomotive::ContentType.logger = Logger.new($stdout)
      # Locomotive::ContentType.db.connection.instance_variable_set(:@logger, Logger.new($stdout))
    end

    context 'unit' do

      before(:each) do
        @field = CustomFields::Field.new(:type => 'String')
      end

      it 'should tell if it is a String' do
        @field.string?.should be_true
      end

      it 'should tell if it is a Text' do
        @field.type = 'Text'
        @field.text?.should be_true
      end

    end

    context 'validation' do

      %w{label type}.each do |key|
        it "should validate presence of #{key}" do
          field = @content_type.entries_custom_fields.build({ :label => 'Shortcut', :type => 'String' }.merge(key.to_sym => nil))
          field.should_not be_valid
          field.errors[key.to_sym].should == ["can't be blank"]
        end
      end

      it 'should not have unique label' do
        field = @content_type.entries_custom_fields.build :label => 'Active', :type => 'Boolean'
        field.should_not be_valid
        field.errors[:label].should == ["is already taken"]
      end

      it 'should invalidate parent if custom field is not valid' do
        field = @content_type.entries_custom_fields.build
        @content_type.should_not be_valid
        @content_type.entries_custom_fields.last.errors[:label].should == ["can't be blank"]
      end

    end

    context 'define core attributes' do

      it 'should have an unique name' do
        @content_type.entries_custom_fields.first._name.should == "custom_field_1"
        @content_type.entries_custom_fields.last._name.should == "custom_field_2"
      end

      it 'should have an unique alias' do
        @content_type.entries_custom_fields.first.name.should == "description"
        @content_type.entries_custom_fields.last.name.should == "active"
      end

    end

    context 'build and save' do

      it 'should build asset' do
        asset = @content_type.entries.build
        lambda {
          asset.description
          asset.active
          asset.custom_fields.size.should == 2
        }.should_not raise_error
      end

      it 'should assign values to newly built asset' do
        asset = build_content_entry(@content_type)
        asset.description.should == 'Lorem ipsum'
        asset.active.should == true
      end

      it 'should save asset' do
        asset = build_content_entry(@content_type)
        asset.save and @content_type.reload
        asset = @content_type.entries.first
        asset.description.should == 'Lorem ipsum'
        asset.active.should == true
      end

      it 'should not modify entries from another collection' do
        asset = build_content_entry(@content_type)
        asset.save and @content_type.reload
        new_collection = Locomotive::ContentType.new
        lambda { new_collection.entries.build.description }.should raise_error
      end

    end

    context 'modifying fields' do

      before(:each) do
        @asset = build_content_entry(@content_type).save
      end

      it 'should add new field' do
        @content_type.entries_custom_fields.build :label => 'Active at', :name => 'active_at', :type => 'Date'
        @content_type.upsert(:validate => false)
        @content_type.invalidate_content_klass
        @content_type.reload
        asset = @content_type.entries.first
        lambda { asset.active_at }.should_not raise_error
      end

      it 'should remove field' do
        @content_type.entries_custom_fields.clear
        @content_type.upsert(:validate => false)
        @content_type.invalidate_content_klass
        @content_type.reload
        asset = @content_type.entries.first
        lambda { asset.active_at }.should raise_error
      end

      it 'should rename field label' do
        @content_type.entries_custom_fields.first.label = 'Simple description'
        @content_type.entries_custom_fields.first.name = nil
        @content_type.upsert(:validate => false)

        @content_type.invalidate_content_klass
        @content_type.reload

        asset = @content_type.entries.first
        asset.simple_description.should == 'Lorem ipsum'
      end

    end

    context 'managing from hash' do

      it 'adds new field' do
        @content_type.entries_custom_fields.clear
        field = @content_type.entries_custom_fields.build :label => 'Title'
        @content_type.entries_custom_fields_attributes = { 0 => { :id => field.id.to_s, 'label' => 'A title', 'type' => 'String' }, 1 => { 'label' => 'Tagline', 'type' => 'String' } }
        @content_type.entries_custom_fields.size.should == 2
        @content_type.entries_custom_fields.first.label.should == 'A title'
        @content_type.entries_custom_fields.last.label.should == 'Tagline'
      end

      it 'updates/removes fields' do
        field = @content_type.entries_custom_fields.build :label => 'Title', :type => 'String'
        @content_type.save; @content_type = Locomotive::ContentType.find(@content_type.id)
        @content_type.update_attributes(:entries_custom_fields_attributes => {
          '0' => { 'id' => lookup_field_id(0), 'label' => 'My Description', 'type' => 'Text', '_destroy' => '1' },
          '1' => { 'id' => lookup_field_id(1), 'label' => 'Active', 'type' => 'Boolean', '_destroy' => '1' },
          '2' => { 'id' => lookup_field_id(2), 'label' => 'My Title !', 'type' => 'String' },
          'new_record' => { 'label' => 'Published at', 'type' => 'String' }
        })
        @content_type = Locomotive::ContentType.find(@content_type.id)
        @content_type.entries_custom_fields.size.should == 2
        @content_type.entries_custom_fields.first.label.should == 'My Title !'
      end

    end

  end

  def build_content_entry(content_type)
    content_type.entries.build(:name => 'Asset on steroids', :description => 'Lorem ipsum', :active => true)
  end

  def lookup_field_id(index)
    @content_type.entries_custom_fields.all[index].id.to_s
  end

end
