# encoding: utf-8

describe Locomotive::EditableElementService do

  let(:site)    { create(:site) }
  let(:home)    { site.pages.home.first }
  let(:account) { create(:account) }
  let(:locale)  { :en }
  let(:service) { described_class.new(site, account, locale) }

  describe '#update_all' do

    before do
      home.update_attributes(
        raw_template: 'Test: {% editable_file banner, fixed: true %}banner.png{% endeditable_file %}{% block body %}{% editable_text bottom %}Bla bla{% endeditable_text %}{% endblock %}',
        editable_elements_attributes: [
          { block: nil, slug: 'banner', fixed: true, default_source_url: 'banner.png', _type: 'Locomotive::EditableFile' },
          { block: 'body', slug: 'bottom', default_content: true, content: 'Bla bla', _type: 'Locomotive::EditableText' }]
      )
    end

    let(:page) {
      create(:sub_page, site: site, parent: home,
        raw_template: '{% extends parent %}{% block body %}{% editable_text top %}Hello world{% endeditable_text %}{% endblock %}',
        editable_elements_attributes: [
          { block: 'body', slug: 'top', default_content: true, content: 'Hello world', _type: 'Locomotive::EditableText' }]
      )
    }

    let(:elements_params) {
      [
        HashWithIndifferentAccess.new('_id' => home.editable_elements.first._id, 'page_id' => home._id, source: FixturedAsset.open('5k.png'), remove_source: '0', remote_source_url: ''),
        HashWithIndifferentAccess.new('_id' => page.editable_elements.first._id, 'page_id' => page._id, content: 'Hello world!')
      ]
    }

    subject { service.update_all(elements_params) }
    it { expect(subject.size).to eq 2 }

    describe 'update pages' do

      before { service.update_all(elements_params) }

      describe 'page with fixed elements' do

        subject { home.reload }

        it { expect(subject.editable_elements.first.source.url).to match /5k\.png\Z/ }
        it { expect(subject.updated_by.name).to eq 'Bart Simpson' }

      end

      describe 'page with simple elements' do

        subject { page.reload }

        it { expect(subject.editable_elements.first.content).to eq 'Hello world!' }
        it { expect(subject.updated_by.name).to eq 'Bart Simpson' }

      end

    end

    context 'localized sites' do

      around(:each) do |example|
        ::Mongoid::Fields::I18n.locale = :nl
        example.run
        ::Mongoid::Fields::I18n.locale = :en
      end

      let!(:site) { create(:site, locales: ['nl', 'en', 'fr']) }

      let(:page) {
        create(:sub_page, site: site, parent: home,
          raw_template: '{% block top %}{% editable_file banner %}banner.png{% endeditable_file %}{% endblock %}')
      }

      let(:elements_params) {
        [
          HashWithIndifferentAccess.new('_id' => page.reload.editable_elements.first._id, 'page_id' => page._id, source: FixturedAsset.open('5k.png'), remove_source: '0', remote_source_url: '')
        ]
      }

      subject { service.update_all(elements_params) }

      it 'can update an editable file, initially created by the API' do
        attributes = { title: 'subpage', editable_elements: [{ content: FixturedAsset.open('wrong.txt'), block: 'top', slug: 'banner', _type: 'file'}] }

        # create the editable file in each locale
        %w(nl fr en).each do |locale|
          ::Mongoid::Fields::I18n.with_locale(locale) do
            _page = Locomotive::Page.find(page._id)
            form = Locomotive::API::Forms::PageForm.new(site, attributes, _page)
            _page.assign_attributes(form.serializable_hash)
            _page.save!
          end
        end

        # save editable_elements with the update_all command
        ::Mongoid::Fields::I18n.with_locale(:en) { subject }

        # make sure it gets successfully saved.
        ::Mongoid::Fields::I18n.with_locale(:en) do
          expect(page.reload.editable_elements.all[0].source.url).to match /5k\.png\Z/
        end
      end

    end

  end

end
