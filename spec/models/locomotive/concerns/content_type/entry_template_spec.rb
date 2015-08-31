# encoding: utf-8

require 'spec_helper'

describe Locomotive::Concerns::ContentType::EntryTemplate do

  before { allow_any_instance_of(Locomotive::Site).to receive(:create_default_pages!).and_return(true) }

  let(:entry_template)  { nil }
  let(:content_type)    { build_content_type(entry_template) }

  describe '#valid?' do

    let(:entry_template) { 'Hello world' }

    before { content_type.valid? }

    subject { content_type.errors }

    it { expect(subject.size).to eq 0 }

    context 'wrong template' do

      let(:entry_template) { '{{ foo' }

      it { expect(subject.size).to eq 1 }
      it { expect(subject[:entry_template]).to eq ["Liquid syntax error: Variable '{{' was not properly terminated with regexp: /\\}\\}/"] }

    end

  end

  describe '#render_entry_template' do

    let(:entry_template) { '{{ entry.title }} world' }
    let(:entry)     { content_type.entries.build(title: 'Hello') }
    let(:registers) { { services: Locomotive::Steam::Services.build_instance } }
    let(:context)   { ::Liquid::Context.new({}, { 'entry' => entry }, registers, true) }

    before { content_type.save! }

    subject { content_type.render_entry_template(context) }

    it { expect(subject).to eq 'Hello world' }

  end

  def build_content_type(entry_template)
    build(:content_type, entry_template: entry_template).tap do |content_type|
      content_type.entries_custom_fields.build label: 'Title', type: 'string'
      content_type.valid?
    end
  end

end
