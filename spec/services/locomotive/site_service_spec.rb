# encoding: utf-8

describe Locomotive::SiteService do

  let(:account) { create(:account) }
  let(:service) { described_class.new(account) }

  describe '#list' do

    subject { service.list }

    it { is_expected.to eq [] }
  end

  describe '#build_new' do

    subject { service.build_new }

    it { expect(subject.handle).not_to eq nil }

  end

  describe '#create' do

    let(:attributes) { { name: 'Acme' } }
    subject { service.create(attributes) }

    it { expect { subject }.to change { Locomotive::Site.count }.by(1) }
    it { expect(subject.handle).not_to eq nil }
    it { expect(subject.created_by).not_to eq nil }

  end

  describe '#create!' do

    let(:attributes) { { name: 'Acme' } }
    subject { service.create!(attributes) }

    it { expect { subject }.to change { Locomotive::Site.count }.by(1) }

    context 'with error' do

      let(:attributes) { {} }

      it { expect { subject }.to raise_error }

    end

  end

  describe '#update' do

    let!(:site)                 { create(:site) }
    let(:attributes)            { { name: 'Acme Corp' } }
    let(:page_service)          { instance_double('PageService', :site= => true) }
    let(:content_entry_service) { instance_double('ContentEntryService', :content_type= => true) }

    before {
      service.page_service          = page_service
      service.content_entry_service = content_entry_service
    }

    subject { service.update(site, attributes) }

    it { is_expected.to eq true }

    context 'locales changed' do

      let(:attributes) { { locales: %w(en fr de) } }

      before { expect(page_service).to receive(:localize).with(%w(fr de), 'en') }

      it { is_expected.to eq true }

    end

    context 'default locale changed' do

      let(:attributes) { { locales: %w(fr en de) } }

      before {
        allow(site).to receive(:localized_content_types).and_return([true])
        expect(page_service).to receive(:localize).with(%w(fr de), 'en')
        expect(content_entry_service).to receive(:localize).with(%w(fr de), 'en')
      }

      it { is_expected.to eq true }

    end

  end

end
