# coding: utf-8

require 'spec_helper'

describe Locomotive::PageParsingService do

  let(:site)    { create(:site) }
  let(:home)    { site.pages.root.first }
  let(:service) { described_class.new(site) }

  describe '#find_or_create_editable_elements' do

    before { home.update_attributes(raw_template: 'Test: {% editable_file banner, fixed: true %}banner.png{% endeditable_file %}{% block body %}{% editable_text bottom %}Bla bla{% endeditable_text %}{% endblock %}') }

    let(:page) { create(:sub_page, site: site, parent: home, raw_template: '{% extends parent %}{% block body %}{% editable_text top %}Hello world{% endeditable_text %}{% endblock %}') }

    subject { service.find_or_create_editable_elements(page, :en) }

    it { expect(subject.size).to eq 3 }
    it { expect { subject }.to change { page.editable_elements.count }.by(2) }

  end

end
