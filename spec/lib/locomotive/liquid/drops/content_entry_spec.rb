require 'spec_helper'

describe Locomotive::Liquid::Drops::ContentEntry do

  describe 'with a file' do

    before { Locomotive::Site.any_instance.stubs(:create_default_pages!).returns(true) }

    let(:content_type) { build_content_type }
    let(:content_entry) { content_type.entries.build(title: 'Locomotive', description: 'Lorem ipsum....', _label_field_name: 'title', created_at: Time.zone.parse('2013-07-05 00:00:00'), file: FixturedAsset.open('5k.png'), updated_at: DateTime.parse('2007-06-29 21:00:00')) }
    let(:content_entry_drop) { Locomotive::Liquid::Drops::ContentEntry.new(content_entry) }

    describe 'displaying the timestamp' do

      subject { render('{{ article.file.url }}', { 'article' => content_entry_drop }) }

      it { should include '5k.png?1183150800' }

    end

  end

  describe 'a list of entries' do

    let(:list) { stub('list', all: true, to_a: %w(a b)) }
    let(:category) { Locomotive::Liquid::Drops::ContentEntry.new(mock('category', projects: list)) }

    subject { render(template, { 'category' => category }) }

    describe 'accessing a has_many relationship' do

      describe 'looping through the list' do

        let(:template) { %({% for project in category.projects %}{{ project }},{% endfor %}) }

        before { list.expects(:filtered).with({ '_visible' => true }, nil).returns(list.to_a) }

        it { should eq 'a,b,' }

      end

      describe 'filtering the list' do

        let(:template) { %({% with_scope order_by: 'name ASC', active: true %}{% for project in category.projects %}{{ project }},{% endfor %}{% endwith_scope %}) }

        before { list.expects(:filtered).with({ 'active' => true, '_visible' => true }, ['name', 'ASC']).returns(list.to_a) }

        it { should eq 'a,b,' }

      end

      describe 'filtering the list with the default order' do

        let(:template) { %({% with_scope active: true %}{% for project in category.projects %}{{ project }},{% endfor %}{% endwith_scope %}) }

        before { list.expects(:filtered).with({ 'active' => true, '_visible' => true }, nil).returns(list.to_a) }

        it { should eq 'a,b,' }

      end

    end

  end

  def render(template, assigns = {})
    liquid_context = ::Liquid::Context.new(assigns, {}, {
      asset_host: TimestampAssetHost.new
    })

    output = ::Liquid::Template.parse(template).render(liquid_context)
    output.gsub(/\n\s{0,}/, '')
  end

  def build_content_type
    FactoryGirl.build(:content_type).tap do |content_type|
      content_type.entries_custom_fields.build label: 'Title', type: 'string'
      content_type.entries_custom_fields.build label: 'Description', type: 'text'
      content_type.entries_custom_fields.build label: 'Visible ?', type: 'boolean', name: 'visible'
      content_type.entries_custom_fields.build label: 'File', type: 'file'
      content_type.entries_custom_fields.build label: 'Published at', type: 'date'
      content_type.valid?
      content_type.send(:set_label_field)
    end
  end

end
