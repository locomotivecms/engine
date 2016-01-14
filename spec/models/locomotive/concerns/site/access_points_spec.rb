require 'spec_helper'

describe Locomotive::Concerns::Site::AccessPoints do

  let(:domains) { [] }
  let(:site) { build(:site, domains: domains) }

  describe '#domains=' do

    it 'downcases the domains' do
      site.domains = ['FIRST.com', 'second.com', 'THIRD.com']

      expect(site.domains).to eq(['first.com', 'second.com', 'third.com'])
    end
  end

  describe '#valid?' do

    subject { site.valid? }

    it { is_expected.to eq true }

    describe 'forbidden domains defined' do

      before { allow(Locomotive.config).to receive(:reserved_domains).and_return(['www.locomotiveapp.com', /.+\.acme\.org/]) }

      let(:domains) { ['example.fr', 'acme.org'] }

      it { is_expected.to eq true }

      context 'setting a forbidden domain name' do

        let(:domains) { ['example.fr', 'www.locomotiveapp.com', 'staging.acme.org'] }

        it 'adds errors for each invalid domain' do
          is_expected.to eq false
          expect(site.errors['domains']).to eq(["www.locomotiveapp.com is already taken", "staging.acme.org is already taken"])
        end

      end

    end

  end

  describe 'domain sync' do

    let!(:listener) { DomainEventListener.new }
    after { listener.shutdown }

    subject { listener }

    describe 'on saving' do

      before  { site.save }

      it 'does not emit an event' do
        expect(subject.size).to eq 0
      end

      context 'new site' do

        let(:domains) { ['www.example.com', 'example.com'] }

        it 'only tracks new domains' do
          expect(subject.added).to eq(['www.example.com', 'example.com'])
          expect(subject.removed).to eq([])
        end

      end

      context 'existing site' do

        let(:domains) { ['www.boring.org', 'www.awesome.io'] }

        before { listener.clear; site.domains = ['www.acme.com', 'www.awesome.io']; site.save; site.reload }

        it 'tracks new domains and removed ones' do
          expect(subject.added).to eq(['www.acme.com'])
          expect(subject.removed).to eq(['www.boring.org'])
        end

      end

    end

    describe 'on destroying' do

      let(:domains) { ['www.example.com', 'example.com'] }

      before { site.save; listener.clear; site.destroy }

      it 'tracks removed domains' do
        expect(subject.added).to eq([])
        expect(subject.removed).to eq(['www.example.com', 'example.com'])
      end

    end

  end

  class DomainEventListener
    def initialize
      @stack = []
      @subscriber = ActiveSupport::Notifications.subscribe('locomotive.site.domain_sync') do |name, start, finish, id, payload|
        emit(name, payload)
      end
    end
    def emit(name, info = {})
      @stack << [name, info]
    end
    def size
      @stack.size
    end
    def added
      @stack.map { |(_, info)| info[:added] }.flatten.compact
    end
    def removed
      @stack.map { |(_, info)| info[:removed] }.flatten.compact
    end
    def clear
      @stack.clear
    end
    def shutdown
      ActiveSupport::Notifications.unsubscribe(@subscriber)
    end
  end

end
