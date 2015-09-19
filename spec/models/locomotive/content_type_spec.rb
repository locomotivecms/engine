require 'spec_helper'

describe Locomotive::ContentType do

  before(:each) do
    allow_any_instance_of(Locomotive::Site).to receive(:create_default_pages!).and_return(true)
  end

  context 'when validating' do

    it 'haves a valid factory' do
      content_type = build(:content_type)
      content_type.entries_custom_fields.build label: 'anything', type: 'string'
      expect(content_type).to be_valid
    end

    # Validations ##

    %w{site name}.each do |field|
      it "requires the presence of #{field}" do
        content_type = build(:content_type, field.to_sym => nil)
        expect(content_type).to_not be_valid
        expect(content_type.errors[field.to_sym]).to eq(["can't be blank"])
      end
    end

    it 'requires the presence of slug' do
      content_type = build(:content_type, name: nil, slug: nil)
      expect(content_type).to_not be_valid
      expect(content_type.errors[:slug]).to eq(["can't be blank"])
    end

    it 'is not valid if slug is not unique' do
      content_type = build(:content_type)
      content_type.entries_custom_fields.build label: 'anything', type: 'string'
      content_type.save
      content_type = build(:content_type, site: content_type.site, slug: content_type.slug)
      expect(content_type).to_not be_valid
      expect(content_type.errors[:slug]).to eq(["is already taken"])
    end

    it 'is not valid if there is not at least one field' do
      content_type = build(:content_type)
      expect(content_type).to_not be_valid
      expect(content_type.errors[:entries_custom_fields]).to eq({ base: ['At least, one custom field is required'] })
    end

    %w(created_at updated_at).each do |name|
      it "does not allow #{name} as name" do
        content_type = build(:content_type)
        field = content_type.entries_custom_fields.build label: 'anything', type: 'string', name: name
        expect(field.valid?).to eq(false)
        expect(field.errors[:name]).to eq(['is reserved'])
      end
    end

    it 'sets a slug from the name before the validation' do
      content_type = build(:content_type, name: 'my content Type')
      content_type.valid?
      expect(content_type.slug).to match(/slug_of_content_type_/)
    end

    it 'make sure the slug is correctly set before the validation' do
      content_type = build(:content_type, slug: 'my content-type')
      content_type.valid?
      expect(content_type.slug).to eq('my_content_type')
    end

  end

  context '#ordered_entries' do

    before(:each) do
      (@content_type = build_content_type(order_by: 'created_at')).save
      @content_2 = @content_type.entries.create name: 'Sacha'
      @content_1 = @content_type.entries.create name: 'Did'
    end

    it 'orders with the ASC direction by default' do
      expect(@content_type.order_direction).to eq('asc')
    end

    it 'has a getter for manual order' do
      expect(@content_type.order_manually?).to eq(false)
      @content_type.order_by = '_position'
      expect(@content_type.order_manually?).to eq(true)
    end

    it 'returns a list of entries ordered manually' do
      @content_type.order_by = '_position'
      expect(@content_type.ordered_entries.collect(&:name)).to eq(%w(Sacha Did))
    end

    it 'returns a list of entries ordered by a column specified by order_by (ASC)' do
      @content_type.order_by = @content_type.entries_custom_fields.where(name: 'name').first._id
      expect(@content_type.ordered_entries.collect(&:name)).to eq(%w(Did Sacha))
    end

    it 'returns a list of entries ordered by a column specified by order_by (DESC)' do
      @content_type.order_by = @content_type.entries_custom_fields.where(name: 'name').first._id
      @content_type.order_direction = 'desc'
      expect(@content_type.ordered_entries.collect(&:name)).to eq(%w(Sacha Did))
    end

    it 'returns a list of contents ordered through condition {order_by: "name asc"}' do
      @content_type.order_by = @content_type.entries_custom_fields.where(name: 'name').first._id
      @content_type.order_direction = 'desc'
      expect(@content_type.ordered_entries(order_by: 'name asc').collect(&:name)).to eq(%w(Did Sacha))
    end

    it 'returns a list of entries ordered by a Date column when first instance is missing the value' do
      @content_type.order_by = @content_type.entries_custom_fields.where(name: 'active_at').first._id
      @content_2.update_attribute :active_at, Date.parse('01/01/2001')
      content_3 = @content_type.entries.create name: 'Mario', active_at: Date.parse('02/02/2001')

      expect(@content_type.ordered_entries.map(&:active_at)).to eq([nil, Date.parse('01/01/2001'), Date.parse('02/02/2001')])

      @content_type.order_direction = 'desc'
      expect(@content_type.ordered_entries.map(&:active_at)).to eq([Date.parse('02/02/2001'), Date.parse('01/01/2001'), nil])
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
        expect(@category_1.projects.relation_metadata.order).to eq(%w(name desc))
        expect(@category_1.projects.sort.map(&:name)).to eq(%w(RubyOnRails LocomotiveCMS).sort)
        expect(@category_1.projects.ordered.all.map(&:name)).to eq(%w(RubyOnRails LocomotiveCMS))
      end

      it 'updates the information about the order of a has_many relationship if the target class changes its order' do
        @content_type.order_by = 'description'; @content_type.order_direction = 'ASC'; @content_type.save!
        @category_1 = safe_find(@category_1.class, @category_1._id)

        expect(@category_1.projects.relation_metadata.order).to eq(%w(description ASC))
        expect(@category_1.projects.map(&:name)).to eq(%w(LocomotiveCMS RubyOnRails))
      end

      it 'uses the order by position if the UI option is enabled' do
        field = @category_content_type.entries_custom_fields.where(name: 'projects').first
        field.ui_enabled = true;

        @category_content_type.save!; @category_1 = safe_find(@category_1.class, @category_1._id)

        expect(@category_1.projects.relation_metadata.order.to_s).to eq('position_in_category')
        expect(@category_1.projects.map(&:name)).to eq(%w(LocomotiveCMS RubyOnRails))
      end

    end

    describe '#list_of_groups' do

      subject { @content_type.send(:list_of_groups) }

      it { expect(subject.size).to eq 2 }
      it { expect(subject[0][:name]).to eq 'Gems' }
      it { expect(subject[1][:name]).to eq 'Service' }

    end

  end

  describe 'custom fields' do

    before(:each) do
      site = build(:site)
      allow(Locomotive::Site).to receive(:find).and_return(site)

      @content_type = build_content_type(site: site)
      # Locomotive::ContentType.logger = Logger.new($stdout)
      # Locomotive::ContentType.db.connection.instance_variable_set(:@logger, Logger.new($stdout))
    end

    context 'validation' do

      %w{label type}.each do |key|
        it "validates presence of #{key}" do
          field = @content_type.entries_custom_fields.build({ label: 'Shortcut', type: 'string' }.merge(key.to_sym => nil))
          expect(field).to_not be_valid
          expect(field.errors[key.to_sym]).to eq(["can't be blank"])
        end
      end

      it 'does not have unique label' do
        field = @content_type.entries_custom_fields.build label: 'Active', type: 'boolean'
        expect(field).to_not be_valid
        expect(field.errors[:label]).to eq(["is already taken"])
      end

      it 'invalidates parent if custom field is not valid' do
        field = @content_type.entries_custom_fields.build
        expect(@content_type).to_not be_valid
        expect(@content_type.entries_custom_fields.last.errors[:label]).to eq(["can't be blank"])
      end

    end

    context 'define core attributes' do

      it 'has an unique name' do
        @content_type.valid?
        expect(@content_type.entries_custom_fields.first.name).to eq('name')
        expect(@content_type.entries_custom_fields.last.name).to eq('active_at')
      end

    end

    context 'build and save' do

      before(:each) do
        @content_type.save
      end

      it 'builds asset' do
        asset = @content_type.entries.build
        expect {
          asset.name
          asset.description
          asset.active
        }.not_to raise_error
      end

      it 'assigns values to newly built asset' do
        asset = build_content_entry(@content_type)
        expect(asset.description).to eq('Lorem ipsum')
        expect(asset.active).to eq(true)
      end

      it 'saves asset' do
        asset = build_content_entry(@content_type)
        asset.save and @content_type.reload
        asset = @content_type.entries.first
        expect(asset.description).to eq('Lorem ipsum')
        expect(asset.active).to eq(true)
      end

      it 'does not modify entries from another content type' do
        asset = build_content_entry(@content_type)
        asset.save and @content_type.reload
        another_content_type = Locomotive::ContentType.new
        expect { another_content_type.entries.build.description }.to raise_error
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
        expect { asset.author }.to_not raise_error
      end

      it 'removes a field' do
        @content_type.entries_custom_fields.destroy_all(name: 'active_at')
        @content_type.save && @content_type.reload
        asset = @content_type.entries.first
        expect { asset.active_at }.to raise_error
      end

      it 'removes the field used as the label when setting the original label_field_name value before' do
        @content_type.label_field_name = 'name'
        @content_type.entries_custom_fields.destroy_all(name: @content_type.label_field_name)
        @content_type.save
        expect(@content_type.label_field_name).to eq('description')
      end

      it 'renames field label' do
        @content_type.entries_custom_fields[1].label = 'Simple description'
        @content_type.entries_custom_fields[1].name = nil
        @content_type.save && @content_type.reload
        asset = @content_type.entries.first
        expect(asset.simple_description).to eq('Lorem ipsum')
      end

    end

    context 'managing from hash' do

      it 'adds new field' do
        @content_type.entries_custom_fields.clear
        field = @content_type.entries_custom_fields.build label: 'Title'
        @content_type.entries_custom_fields_attributes = { 0 => { id: field.id.to_s, 'label' => 'A title', 'type' => 'string' }, 1 => { 'label' => 'Tagline', 'type' => 'sring' } }
        expect(@content_type.entries_custom_fields.size).to eq(2)
        expect(@content_type.entries_custom_fields.first.label).to eq('A title')
        expect(@content_type.entries_custom_fields.last.label).to eq('Tagline')
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

        expect(@content_type.entries_custom_fields.size).to eq(4)
        expect(@content_type.entries_custom_fields.map(&:name)).to eq(%w(name active_at title published_at))
        expect(@content_type.entries_custom_fields[2].label).to eq('My Title !')
      end

    end

  end

  describe 'finding by id or slug' do

    let(:content_type) { build_content_type(slug: 'my_project') }
    let(:id_or_slug) { 'unknown' }

    subject { Locomotive::ContentType.by_id_or_slug(id_or_slug).first }

    before { content_type.save }

    describe 'unknown id' do

      it { should eq nil }

    end

    describe 'existing id' do

      let(:id_or_slug) { content_type._id.to_s }
      it { expect(subject.name).to eq 'My project' }

    end

    describe 'existing slug' do

      let(:id_or_slug) { 'my_project' }
      it { expect(subject.name).to eq 'My project' }

    end

  end

  it_should_behave_like 'model scoped by a site' do

    let(:model)         { build_content_type(slug: 'my_project') }
    let(:attribute)     { :content_version }

  end

  def build_content_type(options = {}, &block)
    build(:content_type, options).tap do |content_type|
      content_type.entries_custom_fields.build label: 'Name',        type: 'string'
      content_type.entries_custom_fields.build label: 'Description', type: 'text'
      content_type.entries_custom_fields.build label: 'Active',      type: 'boolean'
      content_type.entries_custom_fields.build label: 'Active at',   type: 'date'
      block.call(content_type) if block_given?
    end
  end

  def safe_find(klass, id)
    # Mongoid::IdentityMap.clear
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
