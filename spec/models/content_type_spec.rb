require 'spec_helper'

describe ContentType do

  before(:each) do
    Site.any_instance.stubs(:create_default_pages!).returns(true)
  end

  context 'when validating' do

    it 'should have a valid factory' do
      content_type = Factory.build(:content_type)
      content_type.content_custom_fields.build :label => 'anything', :kind => 'String'
      content_type.should be_valid
    end

    # Validations ##

    %w{site name}.each do |field|
      it "should validate presence of #{field}" do
        content_type = Factory.build(:content_type, field.to_sym => nil)
        content_type.should_not be_valid
        content_type.errors[field.to_sym].should == ["can't be blank"]
      end
    end

    it 'should validate presence of slug' do
      content_type = Factory.build(:content_type, :name => nil, :slug => nil)
      content_type.should_not be_valid
      content_type.errors[:slug].should == ["can't be blank"]
    end

    it 'should validate uniqueness of slug' do
      content_type = Factory.build(:content_type)
      content_type.content_custom_fields.build :label => 'anything', :kind => 'String'
      content_type.save
      (content_type = Factory.build(:content_type, :site => content_type.site)).should_not be_valid
      content_type.errors[:slug].should == ["is already taken"]
    end

    it 'should validate size of content custom fields' do
      content_type = Factory.build(:content_type)
      content_type.should_not be_valid
      content_type.errors[:content_custom_fields].should == ["is too small (minimum element number is 1)"]
    end

  end

  context '#ordered_contents' do

    before(:each) do
      @content_type = Factory.build(:content_type, :order_by => 'created_at')
      @content_1 = stub('content_1', :name => 'Did', :_position_in_list => 2)
      @content_2 = stub('content_2', :name => 'Sacha', :_position_in_list => 1)
      @content_type.stubs(:contents).returns([@content_1, @content_2])
    end

    it 'orders with the ASC direction by default' do
      @content_type.asc_order?.should == true
    end

    it 'has a getter for manual order' do
      @content_type.order_manually?.should == false
      @content_type.order_by = '_position_in_list'
      @content_type.order_manually?.should == true
    end

    it 'returns a list of contents ordered manually' do
      @content_type.order_by = '_position_in_list'
      @content_type.ordered_contents.collect(&:name).should == %w(Sacha Did)
    end

    it 'returns a list of contents ordered by a column specified by order_by (ASC)' do
      @content_type.order_by = 'name'
      @content_type.ordered_contents.collect(&:name).should == %w(Did Sacha)
    end

    it 'returns a list of contents ordered by a column specified by order_by (DESC)' do
      @content_type.order_by = 'name'
      @content_type.order_direction = 'desc'
      @content_type.ordered_contents.collect(&:name).should == %w(Sacha Did)
    end

  end

end
