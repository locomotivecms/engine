# encoding: utf-8

describe Locomotive::Concerns::ContentType::PublicSubmissionTitleTemplate do

  before { allow_any_instance_of(Locomotive::Site).to receive(:create_default_pages!).and_return(true) }

  let(:template)     { 'New {{ entry.title }} on {{ site.name }}' }
  let(:content_type) { build_content_type(template) }
  let(:entry)        { content_type.entries.build(title: 'Hello') }

  before { content_type.save! }

  describe '#public_submission_title' do

    subject { content_type.public_submission_title(entry, {}) }

    it { expect(subject).to eq "New Hello on #{content_type.site.name}" }

    context 'extra options become liquid assigns' do

      let(:template) { '{{ prefix }}: {{ entry.title }}' }

      subject { content_type.public_submission_title(entry, { 'prefix' => 'Contact' }) }

      it { expect(subject).to eq 'Contact: Hello' }

    end

    context 'blank template' do

      let(:template) { nil }

      it { expect(subject).to eq '' }

    end

  end

  def build_content_type(template)
    build(:content_type, public_submission_title_template: template).tap do |content_type|
      content_type.entries_custom_fields.build label: 'Title', type: 'string'
      content_type.valid?
    end
  end

end
