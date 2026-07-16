require 'spec_helper'

describe Locomotive::Steam::LiquidParserWithCacheService do

  let(:cache)         { false }
  let(:site)          { build(:site, cache_enabled: cache, template_version: DateTime.parse('2009/09/10 00:00:00')).to_steam }
  let(:parent_finder) { nil}
  let(:service)       { described_class.new(site, parent_finder, nil, 'en') }

  describe '#cache_key' do

    let(:page) { instance_double('ParsedPage', _id: '0001') }

    subject { service.cache_key(page) }

    it { expect(subject).to match %r{\A#{Locomotive::VERSION}/site\/[a-z0-9]+\/template\/1252540800\/page\/0001\/en\Z} }

  end

  describe '#parse' do

    let(:parent)  { instance_double('ParsedParentPage', liquid_source: 'Hello {% block content %}!{% endblock %}', handle: nil, slug: nil) }
    let(:page)    { instance_double('ParsedPage', _id: '0001', liquid_source: '{% extends parent %}{% block content %}world{{ block.super}}{% endblock %}') }
    let(:parent_finder) { instance_double('ParentFinder', find: parent) }

    subject { service.parse(page) }

    it { expect(subject).not_to eq nil }
    it { expect(subject.render).to eq 'Hello world!' }

    it 'does not cache the template' do
      service.parse(page) # warm up the cache
      expect(service).to receive(:_parse)
      subject
    end

    context 'cache enabled' do

      before(:each) { Rails.cache.clear }

      let(:cache) { true }

      it 'does not parse the template twice' do
        service.parse(page) # warm up the cache
        expect(service).not_to receive(:_parse)
        expect(subject.render).to eq 'Hello world!'
      end

    end

  end

  # Characterization of the full marshal/cache round trip: the rendered output
  # of a cache HIT (Marshal.load) must match the cold parse, through the paths
  # a real page exercises at render time (extends + snippet + section).
  describe '#parse with a persisted site graph' do

    before(:each) { Rails.cache.clear }

    let(:mongoid_site) { create(:site, cache_enabled: true) }
    let(:home)         { mongoid_site.pages.root.first }

    let!(:snippet) do
      create(:snippet, site: mongoid_site, slug: 'cached_snippet',
                       template: '<em>from snippet</em>')
    end

    let!(:section) { create(:section, site: mongoid_site) } # slug 'header'

    let(:page) do
      create(:sub_page, site: mongoid_site, parent: home, slug: 'cached-page',
             raw_template: %({% extends parent %}{% block main %}{% include 'cached_snippet' %} {% section header %} inner{% endblock %}))
    end

    let(:services) do
      Locomotive::Steam::Services.build_instance.tap do |services|
        services.set_site(mongoid_site)
        services.locale = :en
      end
    end

    let(:service) do
      described_class.new(services.current_site, services.parent_finder, services.snippet_finder, :en)
    end

    let(:decorated_page) do
      entity = services.repositories.page.build(page.attributes.dup)
      Locomotive::Steam::Decorators::TemplateDecorator.new(entity, :en, mongoid_site.default_locale)
    end

    def render_cached_template(template)
      registers = {
        services: services, page: decorated_page, locale: :en,
        file_system: Locomotive::Steam::Liquid::FileSystem.new(
          section_finder: services.section_finder, snippet_finder: services.snippet_finder)
      }
      template.render(::Liquid::Context.new({}, {}, registers, true))
    end

    before { home.update(raw_template: 'HDR {% block main %}default{% endblock %} FTR') }

    it 'writes the parsed template in the cache and renders the same output from a cache hit' do
      cold_output = render_cached_template(service.parse(decorated_page))

      expect(Rails.cache.read(service.cache_key(decorated_page))).to be_present

      expect(service).not_to receive(:_parse)
      hit_output = render_cached_template(service.parse(decorated_page))

      expect(hit_output).to eq cold_output
      expect(hit_output).to include 'HDR'
      expect(hit_output).to include '<em>from snippet</em>'
      expect(hit_output).to include 'inner'
    end

  end

end
