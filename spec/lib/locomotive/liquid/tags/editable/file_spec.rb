require 'spec_helper'

describe Locomotive::Liquid::Tags::Editable::File do

  before { Locomotive::Site.any_instance.stubs(:create_default_pages!).returns(true) }

  let(:asset_host) { CdnAssetHost.new }
  let(:page) { Locomotive::Page.new(updated_at: DateTime.parse('2007-06-29 21:00:00')) }

  subject { render("{% editable_file banner %}http://www.placehold.it/500x500{% endeditable_file %}") }

  describe 'no uploaded file' do

    let(:asset_host) { IsoAssetHost.new }
    before { add_editable_file({}) }
    it { should eq 'http://www.placehold.it/500x500' }

    context 'a timestamp is not applicable' do

      let(:asset_host) { TimestampAssetHost.new }
      it { should eq 'http://www.placehold.it/500x500' }

    end

  end

  describe 'with a default source url' do

    before { add_editable_file(default_source_url: '/assets/42/assets/1/foo.png') }
    it { should eq 'http://cdn.locomotivecms.com/assets/42/assets/1/foo.png' }

    context 'has a timestamp' do

      let(:asset_host) { TimestampAssetHost.new }
      it { should eq '/assets/42/assets/1/foo.png?1183150800' }

    end

  end

  describe 'with an uploaded file' do

    before { add_editable_file }
    it { should match /^http:\/\/cdn\.locomotivecms\.com\/spec\/(.*)\/5k.png$/ }

    context 'has a timestamp' do

      let(:asset_host) { TimestampAssetHost.new }
      it { should match /^\/spec\/(.*)\/5k.png\?1183150800$/ }

    end

  end

  def render(template, assigns = {})
    liquid_context = ::Liquid::Context.new(assigns, {}, {
      asset_host: asset_host,
      page:       page
    }, true)

    output = ::Liquid::Template.parse(template).render(liquid_context)
    output.gsub(/\n\s{0,}/, '')
  end

  def add_editable_file(attributes = nil)
    attributes ||= { source: FixturedAsset.open('5k.png') }

    editable_file = Locomotive::EditableFile.new({ slug: 'banner' }.merge(attributes))
    page.editable_elements << editable_file
  end

end
