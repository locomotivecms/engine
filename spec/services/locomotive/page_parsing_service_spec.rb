# encoding: utf-8

describe Locomotive::PageParsingService do

  let(:site)    { create(:site) }
  let(:home)    { site.pages.home.first }
  let(:service) { described_class.new(site, :en) }

  describe '#find_all_elements' do

    context 'with sections' do

      let(:home_template) { %({% global_section nav, placement: 'top' %}{% section title, id: 'page_title', placement: 'top' %} {% block body %}{% section random_section %}{% endblock %}{% global_section footer, placement: 'bottom' %}) }
      let(:page_template) { '{% extends parent %}{% block body %}{% sections_dropzone %}{% endblock %}' }

      before { home.update_attributes(raw_template: home_template) }

      let(:page) { create(:sub_page, site: site, parent: home, raw_template: page_template) }

      subject { service.find_all_elements(page)[:sections] }

      it { expect(subject[:top].pluck(:type)).to eq(['nav', 'title']) }
      it { expect(subject[:bottom].pluck(:type)).to eq(['footer']) }
      it { expect(subject[:dropzone]).to eq true }

    end

  end

  describe '#find_or_create_editable_elements' do

    let(:home_template) { 'Test: {% editable_file banner, fixed: true %}banner.png{% endeditable_file %}{% block body %}{% editable_text bottom %}Bla bla{% endeditable_text %}{% endblock %}' }
    let(:page_template) { '{% extends parent %}{% block body %}{% editable_text top %}Hello world{% endeditable_text %}{% endblock %}' }

    before { home.update_attributes(raw_template: home_template) }

    let(:page) { create(:sub_page, site: site, parent: home, raw_template: page_template) }

    subject { service.find_or_create_editable_elements(page)[:elements] }

    it { expect(subject.size).to eq 2 }
    it { expect { subject }.to change { page.editable_elements.count }.by(1) }
    it { expect { subject }.to change { home.reload.editable_elements.count }.by(1) }

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

    context 'editable elements within a snippet (DEPRECATED in v5)' do

      let(:my_snippet) { create(:snippet, slug: 'my_snippet', site: home.site, template: "{% editable_text single_content %}Hello world{% endeditable_text %}") }
      let(:page_template) { "{% block body %}{% include 'my_snippet' %}{% endblock %}" }

      before { my_snippet }

      it { expect(subject.size).to eq 1 }
      it { expect { subject }.to change { page.editable_elements.count }.by(1) }

    end

    describe "don't deal with untyped editable element" do

      before do
        page.editable_elements.create(slug: 'top', block: 'body', content: 'Overridden')
        service.find_or_create_editable_elements(page)
      end

      subject { page.reload.editable_elements.first }

      it { expect(subject.class).to eq(Locomotive::EditableText) }
      it { expect(subject.default_content?).to eq(false) }

    end

  end

  describe '#group_and_sort_editable_elements' do

    let(:list) { [] }

    subject { service.group_and_sort_editable_elements(list) }

    it { expect(subject.size).to eq 0 }

    context 'with some elements' do

      let(:element_1) { instance_double('FakeEditableElementOne', block: nil) }
      let(:element_2) { instance_double('FakeEditableElementTwo', slug: 'Two', block: 'main', priority: 0) }
      let(:element_3) { instance_double('FakeEditableElementThree', slug: 'Three', block: 'main', priority: 1) }

      let(:list) { [[instance_double('FakePage'), element_1], [instance_double('FakePage'), element_2], [instance_double('FakePage'), element_3]] }

      it { expect(subject.size).to eq 2 }
      it { expect(subject['main'].map { |(_, el)| el.slug }).to eq ['Three', 'Two'] }

    end

  end

  describe '#blocks_from_grouped_editable_elements' do

    let(:groups) { {} }

    subject { service.blocks_from_grouped_editable_elements(groups) }

    it { expect(subject.size).to eq 0 }

    context 'with some elements' do

      let(:element_1) { instance_double('FakeEditableElementOne', block: nil, block_label: nil, block_priority: nil) }
      let(:element_2) { instance_double('FakeEditableElementTwo', block: 'main', block_label: 'Main', block_priority: 1) }
      let(:element_3) { instance_double('FakeEditableElementThree', block: 'main', block_label: 'Main', block_priority: 1) }

      let(:groups) {
        {
          nil       => [[instance_double('FakePage'), element_1]],
          'main'    => [
            [instance_double('FakePage'), element_3],
            [instance_double('FakePage'), element_2]
          ],
          'footer'  => []
        }
      }

      it { expect(subject.size).to eq 2 }
      it { expect(subject.map { |b| b[:name] }).to eq ['main', nil] }
      it { expect(subject.map { |b| b[:label] }).to eq ['Main', nil] }

    end

  end

end
