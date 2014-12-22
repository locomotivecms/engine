# coding: utf-8

require 'spec_helper'

describe Locomotive::Site do

  it 'has a valid factory' do
    expect(FactoryGirl.build(:site)).to be_valid
  end

  ## Validations ##

  it 'validates presence of name' do
    site = FactoryGirl.build(:site, name: nil)
    expect(site).to_not be_valid
    expect(site.errors[:name]).to eq(["can't be blank"])
  end

  describe 'domains' do

    let(:domains) { ['goodformat.superlong', 'local.lb-service', 'www.9troisquarts.com', 'nocoffee.photography'] }
    subject { FactoryGirl.build(:site, domains: domains) }

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

  describe 'subdomain' do

    it 'validates presence of subdomain' do
      site = FactoryGirl.build(:site, subdomain: nil)
      expect(site).to_not be_valid
      expect(site.errors[:subdomain]).to eq(["can't be blank"])
    end

    %w{test test42 foo_bar}.each do |subdomain|
      it "accepts subdomain like '#{subdomain}'" do
        expect(FactoryGirl.build(:site, subdomain: subdomain)).to be_valid
      end
    end

    ['-', '_test', 'test_', 't est', '42', '42test'].each do |subdomain|
      it "does not accept subdomain like '#{subdomain}'" do
        site = FactoryGirl.build(:site, subdomain: subdomain)
        expect(site).to_not be_valid
        expect(site.errors[:subdomain]).to eq(['is invalid'])
      end
    end

    it "does not use reserved keywords as subdomain" do
      %w{www admin email blog webmail mail support help site sites}.each do |subdomain|
        site = FactoryGirl.build(:site, subdomain: subdomain)
        expect(site).to_not be_valid
        expect(site.errors[:subdomain]).to eq(['is reserved'])
      end
    end

    it 'validates uniqueness of subdomain' do
      FactoryGirl.create(:site)
      site = FactoryGirl.build(:site)
      expect(site).to_not be_valid
      expect(site.errors[:subdomain]).to eq(["is already taken"])
    end

    it 'validates uniqueness of domains' do
      FactoryGirl.create(:site, domains: %w{www.acme.net www.acme.com})

      site = FactoryGirl.build(:site, domains: %w{www.acme.com})
      expect(site).to_not be_valid
      expect(site.errors[:domains]).to eq(["www.acme.com is already taken"])

      site = FactoryGirl.build(:site, subdomain: 'foo', domains: %w{acme.example.com})
      expect(site).to_not be_valid
      expect(site.errors[:domains]).to eq(["acme.example.com is already taken"])
    end

  end

  ## Named scopes ##

  it 'retrieves sites by domain' do
    site_1 = FactoryGirl.create(:site, domains: %w{www.acme.net})
    site_2 = FactoryGirl.create(:site, subdomain: 'test', domains: %w{www.example.com})

    sites = Locomotive::Site.match_domain('www.acme.net')
    expect(sites.size).to eq(1)
    expect(sites.first).to eq(site_1)

    sites = Locomotive::Site.match_domain('www.example.com')
    expect(sites.size).to eq(1)
    expect(sites.first).to eq(site_2)

    sites = Locomotive::Site.match_domain('test.example.com')
    expect(sites.size).to eq(1)
    expect(sites.first).to eq(site_2)

    sites = Locomotive::Site.match_domain('www.unknown.com')
    expect(sites).to be_empty
  end

  ## Associations ##

  it 'has many accounts' do
    site = FactoryGirl.build(:site)
    account_1, account_2 = FactoryGirl.create(:account), FactoryGirl.create(:account, name: 'homer', email: 'homer@simpson.net')
    site.memberships.build(account: account_1, admin: true)
    site.memberships.build(account: account_2)
    expect(site.memberships.size).to eq(2)
    expect(site.accounts).to eq([account_1, account_2])
  end

  ## Methods ##

  it 'returns domains without subdomain' do
    site = FactoryGirl.create(:site, domains: %w{www.acme.net www.acme.com})
    expect(site.domains).to eq(%w{www.acme.net www.acme.com acme.example.com})
    expect(site.domains_without_subdomain).to eq(%w{www.acme.net www.acme.com})
  end

  describe 'once created' do

    let(:site) { FactoryGirl.create(:site, locales: locales) }

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

      it 'translates the index/404 pages if a new locale is added' do
        site.update_attributes locales: %w(en fr)

        expect(site.errors).to be_empty

        ::Mongoid::Fields::I18n.with_locale('fr') do
          site.pages.root.first.tap do |page|
            expect(page.title).to eq("Page d'accueil")
            expect(page.slug).to eq('index')
          end

          site.pages.not_found.first.tap do |page|
            expect(page.title).to eq('Page non trouvée')
            expect(page.slug).to eq('404')
          end
        end
      end

      it 'translates the index/404 pages if the default locale changes' do
        site.update_attributes locales: %w(fr en)

        expect(site.errors).to be_empty

        ::Mongoid::Fields::I18n.with_locale('fr') do
          site.pages.root.first.tap do |page|
            expect(page.title).to eq("Page d'accueil")
            expect(page.slug).to eq('index')
          end

          site.pages.not_found.first.tap do |page|
            expect(page.title).to eq('Page non trouvée')
            expect(page.slug).to eq('404')
          end
        end
      end

      it 'does not allow to remove the default locale' do
        site.update_attributes locales: %w(fr)
        expect(site.errors[:locales]).to eq(['The previous default locale can not be removed right away.'])
      end

    end

  end

  describe 'deleting in cascade' do

    before(:each) do
      @site = FactoryGirl.create(:site)
    end

    it 'also destroys pages' do
      expect {
        @site.destroy
      }.to change { Locomotive::Page.count }.by(-2)
    end

  end

end
