# encoding: utf-8

describe Locomotive::Membership do

  subject { build(:membership) }

  describe 'validation' do

    it { is_expected.to be_valid }

    it 'requires the presence of an account' do
      subject.account = nil
      expect(subject.valid?).to eq false
      expect(subject.errors[:account]).to eq ["can't be blank"]
    end

    it 'requires the uniqueness of an account' do
      allow(subject.site.memberships).to receive(:where).and_return([1, 2])
      expect(subject.valid?).to eq false
      expect(subject.errors[:account]).to eq ["is already used"]
      expect(subject.errors[:email]).to eq ["is already used"]
    end

  end

  describe "#email" do

    let(:email) { 'john@doe.net' }
    before { subject.email = email }

    it { expect(subject.email).to eq email }

  end

  describe 'roles' do

    it { expect(subject.author?).to eq false }
    it { expect(subject.designer?).to eq false }
    it { expect(subject.admin?).to eq true }

  end

  describe 'parent touch' do

    let(:site)        { create(:site) }
    let(:account)     { create('admin user') }
    let!(:membership) { site.memberships.create!(account: account, role: 'author') }

    it 'does not touch the site when saved' do
      site.set(updated_at: 1.year.ago)

      expect { membership.update!(role: 'admin') }.not_to change { site.reload.updated_at }
    end

  end

end
