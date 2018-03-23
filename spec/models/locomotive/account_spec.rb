# encoding: utf-8

describe Locomotive::Account do

  let!(:existing_account) { create(:account, email: 'another@email.com') }

  it 'has a valid factory' do
    expect(build(:account)).to be_valid
  end

  ## Validations ##
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_presence_of :password }
  it { is_expected.to allow_value('valid@email.com').for(:email) }
  it { is_expected.to allow_value('prefix+suffix@email.com').for(:email) }
  it { is_expected.to_not allow_value('not-an-email').for(:email) }

  it "has a default locale" do
    account = Locomotive::Account.new
    expect(account.locale).to eq('en')
  end

  it "validates the uniqueness of email" do
    account = build(:account, email: existing_account.email)
    expect(account).not_to be_valid
    expect(account.errors[:email]).to eq(["is already taken"])
  end

  ## Associations ##

  it 'owns many sites' do
    account = create(:account)
    site_1  = create(:site, memberships: [Locomotive::Membership.new(account: account)])
    site_2  = create(:site, handle: 'another_one', memberships: [Locomotive::Membership.new(account: account)])
    sites   = [site_1, site_2].map(&:_id)
    expect(account.reload.sites.all? { |s| sites.include?(s._id) }).to eq(true)
  end

  describe 'deleting' do

    before(:each) do
      allow_any_instance_of(Locomotive::Site).to receive(:save).and_return(true)
      @account = build(:account)
      @site_1 = build(:site, memberships: [build(:membership, account: @account)])
      @site_2 = build(:site, memberships: [build(:membership, account: @account)])
      allow(@account).to receive(:sites).and_return([@site_1, @site_2])
    end

    it 'also deletes memberships' do
      allow(@site_1).to receive(:admin_memberships).and_return(['junk', 'dirt'])
      allow(@site_2).to receive(:admin_memberships).and_return(['junk', 'dirt'])
      expect(@site_1.memberships.first).to receive(:destroy)
      expect(@site_2.memberships.first).to receive(:destroy)
      @account.destroy
    end

    it 'raises an exception if account is the only remaining admin' do
      allow(@site_1.memberships.first).to receive(:admin?).and_return(true)
      allow(@site_1).to receive(:admin_memberships).and_return(['junk'])
      expect {
        @account.destroy
      }.to raise_error(Exception, "One admin account is required at least")
    end

  end

  describe '#super_admin?' do

    let(:account) { build(:account, super_admin: true) }
    subject { account.super_admin? }

    it { is_expected.to eq(true) }

    context 'by default' do

      let(:account) { build(:account) }
      it { is_expected.to eq(false) }

    end

  end

  describe '#local_admin?' do

    let(:role)        { 'admin' }
    let(:account)     { create(:account) }
    let(:membership)  { Locomotive::Membership.new(account: account, role: role) }
    let!(:site)       { create(:site, memberships: [membership]) }

    subject { account.local_admin? }

    context 'she/he is an admin for the site' do

      it { is_expected.to eq(true) }

    end

    context 'she/he is an author for the site' do

      let(:role) { 'author' }
      it { is_expected.to eq(false) }

    end

  end

  describe 'api_key' do

    let(:account) { build(:account) }

    it 'is not nil for a new account (after validation)' do
      account.valid?
      expect(account.api_key).to_not eq(nil)
    end

    it 'can be regenerated over and over' do
      key_1 = account.regenerate_api_key
      expect(key_1).to_not eq(nil)
      expect(account.regenerate_api_key).to_not eq(key_1)
    end

  end

end
