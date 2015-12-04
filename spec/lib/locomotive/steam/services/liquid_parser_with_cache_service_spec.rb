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

end
