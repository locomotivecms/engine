# coding: utf-8

require 'spec_helper'

describe Locomotive::Page do

  before(:each) do
    allow_any_instance_of(Locomotive::Site).to receive(:create_default_pages!).and_return(true)
    allow_any_instance_of(Locomotive::Page).to receive(:set_default_raw_template!).and_return(true)
  end

  it 'has a valid factory' do
    expect(build(:page)).to be_valid
  end

  describe 'validation' do

    it 'requires the presence of a site' do
      page = build(:page, site: nil)
      expect(page).to_not be_valid
      expect(page.errors[:site]).to eq(["can't be blank"])
    end

    it 'requires the presence of a title' do
      page = build(:page, title: nil, site: build(:site))
      expect(page).to_not be_valid
      expect(page.errors[:title]).to eq(["can't be blank"])
    end

    it 'requires the presence of the slug' do
      page = build(:page, title: nil, slug: nil)
      expect(page).to_not be_valid
      expect(page.errors[:slug]).to eq(["can't be blank"])
    end

    it 'requires the uniqueness of the slug' do
      page = create(:page)
      another_page = build(:page, site: page.site)
      expect(another_page).to_not be_valid
      expect(another_page.errors[:slug]).to eq(["is already taken"])
    end

    it 'requires the uniqueness of the handle' do
      page = create(:page, handle: 'foo')
      another_page = build(:page, handle: 'foo', site: page.site)
      expect(another_page).to_not be_valid
      expect(another_page.errors[:handle]).to eq(["is already taken"])
    end

    it 'requires the uniqueness of the slug within a "folder"' do
      site = create(:site)
      root = create(:page, slug: 'index', site: site)
      child_1 = create(:page, slug: 'first_child', parent: root, site: site)
      page = build(:page, slug: 'first_child', parent: root, site: site)
      expect(page).to_not be_valid
      expect(page.errors[:slug]).to eq(["is already taken"])

      page.slug = 'index'
      expect(page.valid?).to eq(true)
    end

    %w{admin locomotive stylesheets images javascripts}.each do |slug|
      it "considers '#{slug}' as an invalid slug" do
        page = build(:page, slug: slug)
        allow(page).to receive(:depth).and_return(1)
        expect(page).to_not be_valid
        expect(page.errors[:slug]).to eq(["is reserved"])
      end
    end

    context '#i18n' do

      before(:each) do
        ::Mongoid::Fields::I18n.locale = 'en'
        @page = build(:page, title: 'Hello world')
        ::Mongoid::Fields::I18n.locale = 'fr'
      end

      after(:all) do
        ::Mongoid::Fields::I18n.locale = 'en'
      end

      it 'requires the presence of the title' do
        @page.title = ''
        expect(@page.valid?).to eq(false)
        expect(@page.errors[:title]).to eq(["can't be blank"])
      end

      it 'tells if a page has been translated or not' do
        expect(@page.translated?).to eq(false)
        @page.title = 'Hello world'
        expect(@page.translated?).to eq(true)
      end

    end

  end

  # Named scopes ##

  # Associations ##

  # Methods ##

  describe 'once created' do

    it 'tells if the page is the index one' do
      expect(build(:page, slug: 'index', site: nil).index?).to eq(true)
      page = build(:page, slug: 'index', site: nil)
      allow(page).to receive(:depth).and_return(1)
      expect(page.index?).to eq(false)
    end

    it 'has normalized slug' do
      page = build(:page, slug: ' Valid  ité.html ')
      page.valid?
      expect(page.slug).to eq('valid-ite-dot-html')

      page = build(:page, title: ' Valid  ité.html ', slug: nil, site: page.site)
      expect(page).to be_valid
      expect(page.slug).to eq('valid-ite-dot-html')

      page = build(:page, slug: ' convention_Valid  ité.html ')
      page.valid?
      expect(page.slug).to eq('convention_valid_ite_dot_html')
    end

    it 'has cache enabled' do
      page = build(:page, site: nil)
      expect(page.cache_enabled?).to eq(true)
    end

  end

  describe 'localizing slugs and fullpaths' do

    let(:site)  { create(:site, locales: %w(en fr)) }

    subject { create(:sub_page, site: site) }

    it { expect(subject.slug_translations).to eq('en' => 'subpage', 'fr' => 'subpage') }
    it { expect(subject.fullpath_translations).to eq('en' => 'subpage', 'fr' => 'subpage') }

  end

  describe '#deleting' do

    before(:each) do
      @page = build(:page)
    end

    it 'does not delete the index page' do
      allow(@page).to receive(:index?).and_return(true)
      expect {
        expect(@page.destroy).to eq(false)
        @page.errors.first == 'You can not remove index or 404 pages'
      }.to_not change(Locomotive::Page, :count)
    end

    it 'does not delete the 404 page' do
      allow(@page).to receive(:not_found?).and_return(true)
      expect {
        expect(@page.destroy).to eq(false)
        @page.errors.first == 'You can not remove index or 404 pages'
      }.to_not change(Locomotive::Page, :count)
    end

  end

  describe 'tree organization' do

    before(:each) do
      @home     = create(:page)
      @child_1  = create(:page, title: 'Subpage 1', slug: 'foo', parent_id: @home._id, site: @home.site)
    end

    it 'adds root elements' do
      page_404 = create(:page, title: 'Page not found', slug: '404', site: @home.site)
      expect(Locomotive::Page.roots.count).to eq(2)
      expect(Locomotive::Page.roots).to eq([@home, page_404])
    end

    it 'adds sub pages' do
      child_2 = create(:page, title: 'Subpage 2', slug: 'bar', parent: @home, site: @home.site)
      @home = Locomotive::Page.find(@home.id)
      expect(@home.children.count).to eq(2)
      expect(@home.children).to eq([@child_1, child_2])
    end

    it 'moves its children accordingly' do
      sub_child_1 = create(:page, title: 'Sub Subpage 1', slug: 'bar', parent: @child_1, site: @home.site)
      archives    = create(:page, title: 'archives', slug: 'archives', parent: @home, site: @home.site)
      posts       = create(:page, title: 'posts', slug: 'posts', parent: archives, site: @home.site)

      @child_1.parent = archives
      @child_1.save

      expect(@home.reload.children.count).to eq(1)

      expect(archives.reload.children.count).to eq(2)
      expect(archives.children.last.depth).to eq(2)
      expect(archives.children.last.children.first.depth).to eq(3)

    end

    it 'builds children fullpaths' do
      sub_child_1 = create(:page, title: 'Sub Subpage 1', slug: 'bar', parent: @child_1, site: @home.site)
      expect(sub_child_1.fullpath).to eq("foo/bar")
      @child_1.slug = "milky"
      @child_1.save
      expect(sub_child_1.reload.fullpath).to eq("milky/bar")
    end

    it 'destroys descendants as well' do
      create(:page, title: 'Sub Subpage 1', slug: 'bar', parent_id: @child_1._id, site: @home.site)
      @child_1.destroy
      expect(Locomotive::Page.where(slug: 'bar').first).to eq(nil)
    end

    it 'is scoped by the site' do
      another_home = create(:page, site: create('another site'))
      expect(another_home.position).to eq(0)
    end

  end

  describe 'acts as list' do

    before(:each) do
      @home = create(:page)
      @child_1 = create(:page, title: 'Subpage 1', slug: 'foo', parent: @home, site: @home.site)
      @child_2 = create(:page, title: 'Subpage 2', slug: 'bar', parent: @home, site: @home.site)
      @child_3 = create(:page, title: 'Subpage 3', slug: 'acme', parent: @home, site: @home.site)
    end

    it 'is at the bottom of the folder once created' do
      [@child_1, @child_2, @child_3].each_with_index { |c, i| expect(c.position).to eq(i) }
    end

    it 'has its position updated if a sibling is removed' do
      @child_2.destroy
      [@child_1, @child_3.reload].each_with_index { |c, i| expect(c.position).to eq(i) }
    end

    it 'uses the position passed in attributes when creating a new one' do
      page = create(:page, title: 'Contact', slug: 'contact', position: 42, parent: @home, site: @home.site)
      expect(page.position).to eq(42)
    end

  end

  describe 'templatized extension' do

    let!(:page) { build(:page, parent: build(:page, templatized: false), templatized: true, target_klass_name: 'Foo') }

    it 'is considered as a templatized page' do
      expect(page.templatized?).to eq(true)
    end

    it 'fills in the slug field' do
      page.valid?
      expect(page.slug).to eq('content_type_template')
    end

    it 'returns the target klass' do
      expect(page.target_klass).to eq(Foo)
    end

    it 'has a name for the target entry' do
      expect(page.target_entry_name).to eq('foo')
    end

    it 'uses the find_by_permalink method when fetching the entry' do
      expect(Foo).to receive(:find_by_permalink)
      page.fetch_target_entry('foo')
    end

    it 'does not accept 2 templatized pages in the same folder' do
      @home = create(:page)
      page.attributes = { parent_id: @home._id, site: @home.site }; page.save!

      another_page = build(:page, title: 'Lorem ipsum', parent: @home, site: @home.site, templatized: true, target_klass_name: 'Foo')
      expect(another_page.valid?).to eq(false)
      expect(another_page.errors['slug']).to eq(['is already taken'])
    end

    context '#descendants' do

      before(:each) do
        @home = create(:page)
        page.attributes = { parent_id: @home._id, site: @home.site }; page.save!
        @sub_page = build(:page, title: 'Subpage', slug: 'foo', parent: page, site: @home.site, templatized: false)
      end

      it 'inherits the templatized property from its parent' do
        @sub_page.valid?
        expect(@sub_page.templatized?).to eq(true)
        expect(@sub_page.templatized_from_parent?).to eq(true)
        expect(@sub_page.target_klass_name).to eq('Foo')
      end

      it 'gets templatized if its parent is' do
        page.attributes = { templatized: false, target_klass_name: nil }; page.save!
        expect(@sub_page.save).to eq(true)
        expect(@sub_page.templatized?).to eq(false)

        page.attributes = { templatized: true, target_klass_name: 'Foo' }; page.save!
        @sub_page.reload
        expect(@sub_page.templatized?).to eq(true)
        expect(@sub_page.templatized_from_parent?).to eq(true)
        expect(@sub_page.target_klass_name).to eq('Foo')
      end

      it 'is not templatized if its parent is no more a templatized page' do
        expect(@sub_page.save).to eq(true)
        page.templatized = false; page.save!
        @sub_page.reload
        expect(@sub_page.templatized).to eq(false)
        expect(@sub_page.templatized_from_parent).to eq(false)
        expect(@sub_page.target_klass_name).to be_nil
      end

    end

    context 'using a content type' do

      before(:each) do
        @site = build(:site)
        @content_type = build(:content_type, slug: 'posts', site: @site)
        page.site = @site
        page.target_klass_name = 'Locomotive::ContentEntry5151e25587f643c2cf000001'
      end

      it 'returns nil if the content type does not exit' do
        expect(page.content_type).to be_nil
      end

      it 'has a name for the target entry' do
        allow(@site).to receive(:content_types).and_return(instance_double('ContentType', find: @content_type))
        expect(page.target_entry_name).to eq('post')
      end

      it 'returns the slug of the target klass' do
        allow(@site).to receive(:content_types).and_return(instance_double('ContentType', find: @content_type))
        expect(page.target_klass_slug).to eq('posts')
      end

      it 'returns the target klass in a multi-thread env (mimic it)' do
        page.target_klass_name = 'Locomotive::ContentEntry5151e25587f643c2cf000042'
        Locomotive.send(:remove_const, :'ContentEntry5151e25587f643c2cf000042')
        expect(Locomotive::ContentType).to receive(:find).with('5151e25587f643c2cf000042').and_return(Foo)
        expect(Foo).to receive(:klass_with_custom_fields).and_return(Foo)
        expect(page.target_klass).to eq(Foo)
      end

      context '#security' do

        before(:each) do
          allow(Locomotive::ContentType).to receive(:find).and_return(@content_type)
        end

        it 'is valid if the content type belongs to the site' do
          page.send(:ensure_target_klass_name_security)
          expect(page.errors).to be_empty
        end

        it 'does not valid the page if the content type does not belong to the site' do
          @content_type.site = build(:site)
          page.send(:ensure_target_klass_name_security)
          expect(page.errors[:target_klass_name]).to eq(['presents a security problem'])
        end

      end

    end

  end

  describe 'listed extension' do

    it 'is considered as a visible page' do
      @page = build(:page, site: nil)
      expect(@page.listed?).to eq(true)
    end

    it 'is not considered as a visible page' do
      @page = build(:page, site: nil, listed: false)
      expect(@page.listed?).to eq(false)
    end

  end

  describe 'redirect extension' do

    before(:each) do
      @page = build(:page, site: nil, redirect: true, redirect_url: 'http://www.google.com/')
    end

    it 'is considered as a redirect page' do
      expect(@page.redirect?).to eq(true)
    end

    it 'validates the redirect_url if redirect is set' do
      @page.redirect_url = nil
      expect(@page).to_not be_valid
      expect(@page.errors[:redirect_url]).to eq(["can't be blank"])
    end

    it 'should validate format of redirect_url' do
      @page.redirect_url = "invalid url with spaces"
      expect(@page).to_not be_valid
      expect(@page.errors[:redirect_url]).to eq(["is invalid"])
    end
  end

  describe 'response type' do

    before(:each) do
      @page = build(:page, site: nil)
    end

    it 'is a HTML document by default' do
      expect(@page.response_type).to eq('text/html')
      expect(@page.default_response_type?).to eq(true)
    end

    it 'can also be a JSON document' do
      @page.response_type = 'application/json'
      expect(@page.default_response_type?).to eq(false)
    end

  end

  it_should_behave_like 'model scoped by a site' do

    let(:model)     { create(:page) }
    let(:attribute) { :content_version }

    describe 'the raw_template has been modified' do

      let(:date) { Time.zone.local(2015, 4, 1, 12, 0, 0) }

      it 'updates the template_version attribute of the site' do
        model.raw_template = 'new one'
        Timecop.freeze(date) do
          expect { model.save! }.to change { site.template_version }.to date
        end
      end

    end

  end

  class Foo
  end

  class Locomotive::ContentEntry5151e25587f643c2cf000001
  end

  class Locomotive::ContentEntry5151e25587f643c2cf000042
  end

  def fake_bson_id(id)
    BSON::ObjectId.from_string(id.to_s.rjust(24, '0'))
  end

end
