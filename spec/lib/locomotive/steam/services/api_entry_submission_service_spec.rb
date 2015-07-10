require 'spec_helper'

describe Locomotive::Steam::APIEntrySubmissionService do

  let(:site)          { create(:site) }
  let(:locale)        { :en }
  let!(:content_type) { create('message content type', site: site).reload }
  let(:service)       { described_class.new(site, locale) }

  describe '#submit' do

    let(:attributes) { { 'name' => 'John Doe', 'message' => 'Hello' } }

    subject { service.submit(content_type.slug, attributes) }

    it { expect { subject }.to change { content_type.entries.count } }

    it 'returns a content entry' do
      expect(subject.name).to eq 'John Doe'
      expect(subject.message).to eq 'Hello'
    end

  end #

  describe '#to_json' do

    let(:entry) { content_type.entries.build(_id: 42, name: 'John Doe', message: 'Hello') }

    subject { service.to_json(entry) }

    it 'includes _id and fields' do
      expect(subject).to match('"_id":"42"')
      expect(subject).to match('"name":"John Doe"')
      expect(subject).to match('"message":"Hello"')
    end

  end

end
