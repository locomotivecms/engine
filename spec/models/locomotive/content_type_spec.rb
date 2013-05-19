require 'spec_helper'

describe Locomotive::ContentType do

  before(:each) do
    Locomotive::Site.any_instance.stubs(:create_default_pages!).returns(true)
  end

  context 'when validating' do

    it 'should have a valid factory' do
      content_type = FactoryGirl.build(:content_type)
      content_type.entries_custom_fields.build label: 'anything', type: 'string'
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
      content_type = FactoryGirl.build(:content_type, name: nil, slug: nil)
      content_type.should_not be_valid
      content_type.errors[:slug].should == ["can't be blank"]
    end

    it 'is not valid if slug is not unique' do
      content_type = FactoryGirl.build(:content_type)
      content_type.entries_custom_fields.build label: 'anything', type: 'string'
      content_type.save
      (content_type = FactoryGirl.build(:content_type, site: content_type.site)).should_not be_valid
      content_type.errors[:slug].should == ["is already taken"]
    end

    it 'is not valid if there is not at least one field' do
      content_type = FactoryGirl.build(:content_type)
      content_type.should_not be_valid
      content_type.errors[:entries_custom_fields].should == { base: ['At least, one custom field is required'] }
    end

    %w(created_at updated_at).each do |name|
      it "does not allow #{name} as name" do
        content_type = FactoryGirl.build(:content_type)
        field = content_type.entries_custom_fields.build label: 'anything', type: 'string', name: name
        field.valid?.should be_false
        field.errors[:name].should == ['is reserved']
      end
    end

    it 'sets a slug from the name before the validation' do
      content_type = FactoryGirl.build(:content_type, name: 'my content Type')
      content_type.valid?
      content_type.slug.should == 'my_content_type'
    end

    it 'make sure the slug is correctly set before the validation' do
      content_type = FactoryGirl.build(:content_type, slug: 'my content-type')
      content_type.valid?
      content_type.slug.should == 'my_content_type'
    end

  end

  context '#ordered_entries' do

    before(:each) do
      (@content_type = build_content_type(order_by: 'created_at')).save
      @content_2 = @content_type.entries.create name: 'Sacha'
      @content_1 = @content_type.entries.create name: 'Did'
    end

    it 'orders with the ASC direction by default' do
      @content_type.order_direction.should == 'asc'
    end

    it 'has a getter for manual order' do
      @content_type.order_manually?.should == false
      @content_type.order_by = '_position'
      @content_type.order_manually?.should == true
    end

    it 'returns a list of entries ordered manually' do
      @content_type.order_by = '_position'
      @content_type.ordered_entries.collect(&:name).should == %w(Sacha Did)
    end

    it 'returns a list of entries ordered by a column specified by order_by (ASC)' do
      @content_type.order_by = @content_type.entries_custom_fields.where(name: 'name').first._id
      @content_type.ordered_entries.collect(&:name).should == %w(Did Sacha)
    end

    it 'returns a list of entries ordered by a column specified by order_by (DESC)' do
      @content_type.order_by = @content_type.entries_custom_fields.where(name: 'name').first._id
      @content_type.order_direction = 'desc'
      @content_type.ordered_entries.collect(&:name).should == %w(Sacha Did)
    end

    it 'returns a list of contents ordered through condition {order_by: "name asc"}' do
      @content_type.order_by = @content_type.entries_custom_fields.where(name: 'name').first._id
      @content_type.order_direction = 'desc'
      @content_type.ordered_entries(order_by: 'name asc').collect(&:name).should == %w(Did Sacha)
    end

    it 'returns a list of entries ordered by a Date column when first instance is missing the value' do
      @content_type.order_by = @content_type.entries_custom_fields.where(name: 'active_at').first._id
      @content_2.update_attribute :active_at, Date.parse('01/01/2001')
      content_3 = @content_type.entries.create name: 'Mario', active_at: Date.parse('02/02/2001')

      @content_type.ordered_entries.map(&:active_at).should == [nil, Date.parse('01/01/2001'), Date.parse('02/02/2001')]

      @content_type.order_direction = 'desc'
      @content_type.ordered_entries.map(&:active_at).should == [Date.parse('02/02/2001'), Date.parse('01/01/2001'), nil]
    end

  end

  describe 'belongs_to/has_many relationship' do

    before(:each) do
      build_belongs_to_has_many_relationship

      @category_1 = @category_content_type.entries.create name: 'Gems'
      @category_2 = @category_content_type.entries.create name: 'Service'

      @content_1 = @content_type.entries.create name: 'Github',        category: @category_2
      @content_2 = @content_type.entries.create name: 'LocomotiveCMS', category: @category_1, description: 'Lorem ipsum',  _position_in_category: 1
      @content_3 = @content_type.entries.create name: 'RubyOnRails',   category: @category_1, description: 'Zzzzzz',       _position_in_category: 2
    end

    context '#ordering in a belongs_to/has_many relationship' do

      it 'orders projects based on the default order of the Project content type' do
        @category_1.projects.metadata.order.should == %w(name desc)
        @category_1.projects.map(&:name).should == %w(RubyOnRails LocomotiveCMS)
        @category_1.projects.ordered.all.map(&:name).should == %w(RubyOnRails LocomotiveCMS)
      end

      it 'updates the information about the order of a has_many relationship if the target class changes its order' do
        @content_type.order_by = 'description'; @content_type.order_direction = 'ASC'; @content_type.save!
        @category_1 = safe_find(@category_1.class, @category_1._id)

        @category_1.projects.metadata.order.should == %w(description ASC)
        @category_1.projects.map(&:name).should == %w(LocomotiveCMS RubyOnRails)
      end

      it 'uses the order by position if the UI option is enabled' do
        field = @category_content_type.entries_custom_fields.where(name: 'projects').first
        field.ui_enabled = true;

        @category_content_type.save!; @category_1 = safe_find(@category_1.class, @category_1._id)

        @category_1.projects.metadata.order.to_s.should == 'position_in_category'
        @category_1.projects.map(&:name).should == %w(LocomotiveCMS RubyOnRails)
      end

    end

    context '#group_by belongs_to field' do

      it 'groups entries' do
        groups = @content_type.send(:group_by_belongs_to_field, @content_type.group_by_field)

        groups.map { |h| h[:name] }.should == %w(Gems Service)

        groups.first[:entries].map(&:name).should == %w(RubyOnRails LocomotiveCMS)
        groups.last[:entries].map(&:name).should == %w(Github)
      end

      it 'groups entries with a different columns order' do
        @category_content_type.update_attributes order_by: @category_content_type.entries_custom_fields.first._id, order_direction: 'desc'
        groups = @content_type.send(:group_by_belongs_to_field, @content_type.group_by_field)

        groups.map { |h| h[:name] }.should == %w(Service Gems)
      end

      it 'deals with entries without a value for the group_by field (orphans)' do
        @content_type.entries.create name: 'MacOsX'
        groups = @content_type.send(:group_by_belongs_to_field, @content_type.group_by_field)

        groups.map { |h| h[:name] }.should == ['Gems', 'Service', nil]

        groups.last[:entries].map(&:name).should == %w(MacOsX)
      end

    end

  end

  describe 'custom fields' do

    before(:each) do
      site = FactoryGirl.build(:site)
      Locomotive::Site.stubs(:find).returns(site)

      @content_type = build_content_type(site: site)
      # Locomotive::ContentType.logger = Logger.new($stdout)
      # Locomotive::ContentType.db.connection.instance_variable_set(:@logger, Logger.new($stdout))
    end

    context 'validation' do

      %w{label type}.each do |key|
        it "should validate presence of #{key}" do
          field = @content_type.entries_custom_fields.build({ label: 'Shortcut', type: 'string' }.merge(key.to_sym => nil))
          field.should_not be_valid
          field.errors[key.to_sym].should == ["can't be blank"]
        end
      end

      it 'should not have unique label' do
        field = @content_type.entries_custom_fields.build label: 'Active', type: 'boolean'
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
        @content_type.valid?
        @content_type.entries_custom_fields.first.name.should == 'name'
        @content_type.entries_custom_fields.last.name.should == 'active_at'
      end

    end

    context 'build and save' do

      before(:each) do
        @content_type.save
      end

      it 'should build asset' do
        asset = @content_type.entries.build
        lambda {
          asset.name
          asset.description
          asset.active
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

      it 'should not modify entries from another content type' do
        asset = build_content_entry(@content_type)
        asset.save and @content_type.reload
        another_content_type = Locomotive::ContentType.new
        lambda { another_content_type.entries.build.description }.should raise_error
      end

    end

    context 'modifying fields' do

      before(:each) do
        @content_type.save
        @asset = build_content_entry(@content_type).save
      end

      it 'adds new field' do
        @content_type.entries_custom_fields.build label: 'Author', name: 'author', type: 'string'
        @content_type.save && @content_type.reload
        asset = @content_type.entries.first
        lambda { asset.author }.should_not raise_error
      end

      it 'removes a field' do
        @content_type.entries_custom_fields.destroy_all(name: 'active_at')
        @content_type.save && @content_type.reload
        asset = @content_type.entries.first
        lambda { asset.active_at }.should raise_error
      end

      it 'removes the field used as the label when setting the original label_field_name value before' do
        @content_type.label_field_name = 'name'
        @content_type.entries_custom_fields.destroy_all(name: @content_type.label_field_name)
        @content_type.save
        @content_type.label_field_name.should == 'description'
      end

      it 'renames field label' do
        @content_type.entries_custom_fields[1].label = 'Simple description'
        @content_type.entries_custom_fields[1].name = nil
        @content_type.save && @content_type.reload
        asset = @content_type.entries.first
        asset.simple_description.should == 'Lorem ipsum'
      end

    end

    context 'managing from hash' do

      it 'adds new field' do
        @content_type.entries_custom_fields.clear
        field = @content_type.entries_custom_fields.build label: 'Title'
        @content_type.entries_custom_fields_attributes = { 0 => { id: field.id.to_s, 'label' => 'A title', 'type' => 'string' }, 1 => { 'label' => 'Tagline', 'type' => 'sring' } }
        @content_type.entries_custom_fields.size.should == 2
        @content_type.entries_custom_fields.first.label.should == 'A title'
        @content_type.entries_custom_fields.last.label.should == 'Tagline'
      end

      it 'updates/removes fields' do
        @content_type.save

        field = @content_type.entries_custom_fields.build label: 'Title', type: 'string'
        @content_type.save

        @content_type.update_attributes(entries_custom_fields_attributes: {
          '0' => { '_id' => lookup_field_id(1), 'label' => 'My Description', 'type' => 'text', '_destroy' => '1' },
          '1' => { '_id' => lookup_field_id(2), 'label' => 'Active', 'type' => 'boolean', '_destroy' => '1' },
          '2' => { '_id' => field._id, 'label' => 'My Title !' },
          '3' => { 'label' => 'Published at', 'type' => 'string' }
        })

        @content_type = Locomotive::ContentType.find(@content_type.id)

        @content_type.entries_custom_fields.size.should == 4
        @content_type.entries_custom_fields.map(&:name).should == %w(name active_at title published_at)
        @content_type.entries_custom_fields[2].label.should == 'My Title !'
      end

    end

  end

  def build_content_type(options = {}, &block)
    FactoryGirl.build(:content_type, options).tap do |content_type|
      content_type.entries_custom_fields.build label: 'Name',        type: 'string'
      content_type.entries_custom_fields.build label: 'Description', type: 'text'
      content_type.entries_custom_fields.build label: 'Active',      type: 'boolean'
      content_type.entries_custom_fields.build label: 'Active at',   type: 'date'
      block.call(content_type) if block_given?
    end
  end

  def safe_find(klass, id)
    Mongoid::IdentityMap.clear
    # Rails.logger.debug "---> reload #{klass}, #{id}!!!!!"
    klass.find(id)
  end

  def build_content_entry(content_type)
    content_type.entries.build(name: 'Asset on steroids', description: 'Lorem ipsum', active: true)
  end

  def build_belongs_to_has_many_relationship
    (@category_content_type = build_content_type(name: 'Categories')).save!
    category_klass = @category_content_type.klass_with_custom_fields(:entries).name

    @content_type = build_content_type.tap do |content_type|
      field = content_type.entries_custom_fields.build label: 'Category', type: 'belongs_to', class_name: category_klass
      content_type.order_by           = 'name'
      content_type.order_direction    = 'desc'
      content_type.group_by_field_id  = field._id
      content_type.save!
    end
    project_klass = @content_type.klass_with_custom_fields(:entries).name

    field = @category_content_type.entries_custom_fields.build label: 'Projects', type: 'has_many', class_name: project_klass, inverse_of: :category, ui_enabled: false
    @category_content_type.save!
  end

  def lookup_field_id(index)
    @content_type.entries_custom_fields.all[index].id.to_s
  end

end
