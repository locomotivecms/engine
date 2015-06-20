# coding: utf-8

require 'spec_helper'

describe Locomotive::EditableElementService do

  let(:site)    { create(:site) }
  let(:home)    { site.pages.root.first }
  let(:account) { create(:account) }
  let(:service) { described_class.new(site, account) }

  describe '#update_all' do

    before do
      home.update_attributes(
        raw_template: 'Test: {% editable_file banner, fixed: true %}banner.png{% endeditable_file %}{% block body %}{% editable_text bottom %}Bla bla{% endeditable_text %}{% endblock %}',
        editable_elements_attributes: [
          { block: nil, slug: 'baner', fixed: true, default_source_url: 'banner.png', _type: 'Locomotive::EditableFile' },
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
      HashWithIndifferentAccess.new({
        '0' => { 'id' => home.editable_elements.first._id, 'page_id' => home._id, source: FixturedAsset.open('5k.png') },
        '1' => { 'id' => page.editable_elements.first._id, 'page_id' => page._id, content: 'Hello world!' }
      })
    }

    subject { service.update_all(elements_params) }
    it { expect(subject).to eq true }

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

  end

end
