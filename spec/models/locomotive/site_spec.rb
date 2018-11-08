# encoding: utf-8

describe Locomotive::Site do

  it 'has a valid factory' do
    expect(build(:site)).to be_valid
  end

  ## Validations ##

  it 'validates presence of name' do
    site = build(:site, name: nil)
    expect(site).to_not be_valid
    expect(site.errors[:name]).to eq(["can't be blank"])
  end

  describe 'domains' do

    let(:domains) { ['goodformat.superlong', 'local.lb-service', 'www.9troisquarts.com', 'nocoffee.photography'] }
    subject { build(:site, domains: domains) }

    it { is_expected.to be_valid }

    context 'bad format' do

      let(:domains) { ['barformat.a', '-foo.net'] }

      it { is_expected.to_not be_valid }
      it 'tells what domains are invalid' do
        subject.valid?
        expect(subject.errors[:domains]).to eq(['barformat.a is invalid', '-foo.net is invalid'])
      end

    end

  end

  describe 'asset_host' do

    let(:asset_host) { nil }
    subject { build(:site, asset_host: asset_host) }

    it { is_expected.to be_valid }

    context 'good format without protocol' do

      let(:asset_host) { 'asset.dev' }

      it { is_expected.to be_valid}

    end

    context 'good format with protocol' do

      let(:asset_host) { 'https://asset.dev' }

      it { is_expected.to be_valid}

    end

    context 'bad format' do

      let(:asset_host) { 'http://asset.d' }

      it { is_expected.to_not be_valid }

      it 'tells if asset_host is invalid' do
        subject.valid?
        expect(subject.errors[:asset_host]).to eq(['http://asset.d is invalid'])
      end
    end
  end

  describe 'handle' do

    it 'validates presence of handle' do
      site = build(:site, handle: nil)
      expect(site).to_not be_valid
      expect(site.errors[:handle]).to eq(["can't be blank"])
    end

    %w{test test42 foo_bar}.each do |handle|
      it "accepts handle like '#{handle}'" do
        expect(build(:site, handle: handle)).to be_valid
      end
    end

    ['-', '_test', 'test_', 't est', '42', '42test'].each do |handle|
      it "does not accept handle like '#{handle}'" do
        site = build(:site, handle: handle)
        expect(site).to_not be_valid
        expect(site.errors[:handle]).to eq(['is invalid'])
      end
    end

    it "does not use reserved keywords as handle" do
      %w{sign_in sign_out sites my_account}.each do |handle|
        site = build(:site, handle: handle)
        expect(site).to_not be_valid
        expect(site.errors[:handle]).to eq(['is reserved'])
      end
    end

    it 'validates uniqueness of handle' do
      create(:site)
      site = build(:site)
      expect(site).to_not be_valid
      expect(site.errors[:handle]).to eq(["is already taken"])
    end

    it 'validates uniqueness of domains' do
      create(:site, domains: %w{www.acme.net www.acme.com})

      site = build(:site, domains: %w{www.acme.com})
      expect(site).to_not be_valid
      expect(site.errors[:domains]).to eq(["www.acme.com is already taken"])
    end

  end

  ## Named scopes ##

  it 'retrieves sites by domain' do
    site_1 = create(:site, domains: %w{www.acme.net})
    site_2 = create(:site, handle: 'test', domains: %w{www.example.com})

    sites = Locomotive::Site.match_domain('www.acme.net')
    expect(sites.size).to eq(1)
    expect(sites.first._id).to eq(site_1._id)

    sites = Locomotive::Site.match_domain('www.example.com')
    expect(sites.size).to eq(1)
    expect(sites.first._id).to eq(site_2._id)

    sites = Locomotive::Site.match_domain('www.unknown.com')
    expect(sites).to be_empty
  end

  ## Associations ##

  it 'has many accounts' do
    site = build(:site)
    account_1, account_2 = create(:account), create(:account, name: 'homer', email: 'homer@simpson.net')
    site.memberships.build(account: account_1, admin: true)
    site.memberships.build(account: account_2)
    expect(site.memberships.size).to eq(2)
    expect(site.accounts.to_a).to eq([account_1, account_2])
  end

  ## Methods ##

  describe 'once created' do

    let(:site) { create(:site, locales: locales) }

    context 'the default locale is fr' do

      let(:locales) { ['fr'] }

      it 'creates the index and 404 pages' do
        expect(site.pages.size).to eq(2)

        expect(site.pages.map(&:fullpath).sort).to eq([nil, nil])

        ::Mongoid::Fields::I18n.with_locale('fr') do
          expect(site.pages.map(&:fullpath).sort).to eq(%w{404 index})
        end
      end

    end

    context 'the default locale is en' do

      let(:locales) { ['en'] }

      it 'should create the index and 404 pages' do
        expect(site.pages.size).to eq(2)
        expect(site.pages.map(&:fullpath).sort).to eq(%w{404 index})
      end

      it 'does not allow to remove the default locale' do
        site.update_attributes locales: %w(fr)
        expect(site.errors[:locales]).to eq(['The previous default locale can not be removed right away.'])
        site.update_attributes locales: [:en]
        expect(site.errors[:locales]).to eq []
      end

    end

  end

  describe 'deleting in cascade' do

    let!(:site) { create(:site) }

    it 'also destroys pages' do
      expect {
        site.destroy
      }.to change { Locomotive::Page.count }.by(-2)
    end

  end

end
