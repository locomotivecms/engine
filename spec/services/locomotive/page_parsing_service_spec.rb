# coding: utf-8

require 'spec_helper'

describe Locomotive::PageParsingService do

  let(:site)    { create(:site) }
  let(:home)    { site.pages.root.first }
  let(:service) { described_class.new(site, :en) }

  describe '#find_or_create_editable_elements' do

    let(:home_template) { 'Test: {% editable_file banner, fixed: true %}banner.png{% endeditable_file %}{% block body %}{% editable_text bottom %}Bla bla{% endeditable_text %}{% endblock %}' }
    let(:page_template) { '{% extends parent %}{% block body %}{% editable_text top %}Hello world{% endeditable_text %}{% endblock %}' }

    before { home.update_attributes(raw_template: home_template) }

    let(:page) { create(:sub_page, site: site, parent: home, raw_template: page_template) }

    subject { service.find_or_create_editable_elements(page) }

    it { expect(subject.size).to eq 2 }
    it { expect { subject }.to change { page.editable_elements.count }.by(1) }

    context 'super called' do

      let(:page_template) { '{% extends parent %}{% block body %}{% editable_text top %}Hello world{% endeditable_text %}{{ block.super }}{% endblock %}' }

      it { expect(subject.size).to eq 3 }
      it { expect { subject }.to change { page.editable_elements.count }.by(2) }

    end

    context 'replacing a whole block' do

      let(:home_template) { 'Test: {% block body %}{% editable_text main %}Content{% endeditable_text %}{% block sidebar %}Sidebar{% endblock %}{% endblock %}' }
      let(:page_template) { '{% extends parent %}{% block body %}{% editable_text single_content %}Hello world{% endeditable_text %}{% endblock %}' }

      it { expect(subject.size).to eq 1 }
      it { expect { subject }.to change { page.editable_elements.count }.by(1) }

      context 'replacing a nested block' do

        let(:page_template) { '{% extends parent %}{% block "body/sidebar" %}{{ block.super }}{% editable_text ads %}Ads{% endeditable_text %}{% endblock %}' }

        it { expect(subject.size).to eq 2 }
        it { expect { subject }.to change { page.editable_elements.count }.by(2) }

      end

    end

  end

end
