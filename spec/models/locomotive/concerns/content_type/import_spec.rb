# encoding: utf-8

describe Locomotive::Concerns::ContentType::Import do

  before { allow_any_instance_of(Locomotive::Site).to receive(:create_default_pages!).and_return(true) }

  let(:enabled) { true }
  let(:raw_import_state) { nil }
  let(:content_type) { build_content_type(enabled, raw_import_state) }

  describe '#can_import?' do
    subject { content_type.can_import? }
    it { is_expected.to eq true }
    context 'the feature is disabled' do
      let(:enabled) { false }
      it { is_expected.to eq false }
    end
    context 'the import is in progress' do
      let(:raw_import_state) { { 'status' => 'in_progress' } }
      it { is_expected.to eq false }
    end
    context 'the import is done' do
      let(:raw_import_state) { { 'status' => 'done' } }
      it { is_expected.to eq true }
    end    
  end

  describe '#import_status' do
    subject { content_type.import_status }
    it { is_expected.to eq :ready }
    context 'the import is in progress' do
      let(:raw_import_state) { { 'status' => 'in_progress' } }
      it { is_expected.to eq :in_progress }
    end
    context 'the import is done' do
      let(:raw_import_state) { { 'status' => 'done' } }
      it { is_expected.to eq :done }
    end
  end  

  describe '#start_import' do
    before { content_type.save }
    subject { content_type.start_import(total: 42) }
    it 'changes the import status' do
      expect { subject }.to change { content_type.reload.import_status }.from(:ready).to(:in_progress)
      .and change { content_type.import_state.total_rows }.from(nil).to(42)
    end
  end

  describe '#on_imported_row' do
    before { content_type.save }
    let(:status) { :created }
    subject { content_type.on_imported_row(6, status) }
    context 'new entry created' do      
      it 'changes the number of processed rows' do
        expect { subject }.to change { content_type.import_state.processed_rows_count }.from(0).to(1)
        .and change { content_type.import_state.created_rows_count }.from(0).to(1)
        .and change { content_type.import_state.updated_rows_count }.by(0)
        .and change { content_type.import_state.failed_rows_count }.by(0)
      end
    end
    context 'entry updated' do
      let(:status) { :updated }
      it 'changes the number of processed rows' do
        expect { subject }.to change { content_type.import_state.processed_rows_count }.from(0).to(1)
        .and change { content_type.import_state.created_rows_count }.by(0)
        .and change { content_type.import_state.updated_rows_count }.from(0).to(1)
        .and change { content_type.import_state.failed_rows_count }.by(0)
      end
    end
    context 'invalid entry' do
      let(:status) { :failed }
      it 'changes the number of processed rows' do
        expect { subject }.to change { content_type.import_state.processed_rows_count }.from(0).to(1)
        .and change { content_type.import_state.created_rows_count }.by(0)
        .and change { content_type.import_state.updated_rows_count }.by(0)
        .and change { content_type.import_state.failed_rows_count }.from(0).to(1)
        .and change { content_type.import_state.failed_rows_ids }.from([]).to([6])
      end
    end
    context 'chaining multiple calls' do
      it 'keeps track of the previous state' do
        expect {
          content_type.on_imported_row(0, :created)
          content_type.on_imported_row(1, :updated)
          content_type.on_imported_row(2, :failed)
          content_type.on_imported_row(3, :updated)
        }.to change { content_type.import_state.created_rows_count }.from(0).to(1)
        .and change { content_type.import_state.updated_rows_count }.from(0).to(2)
        .and change { content_type.import_state.failed_rows_count }.from(0).to(1)
      end
    end
  end

  describe '#finish_import' do
    let(:raw_import_state) { { 'status' => 'in_progress' } }
    before { content_type.save }
    subject { content_type.finish_import }
    it 'changes the import status' do
      expect { subject }.to change { content_type.reload.import_status }.from(:in_progress).to(:done)
    end
  end

  describe '#cancel_import' do
    let(:raw_import_state) { { 'status' => 'in_progress' } }
    before { content_type.save }
    subject { content_type.cancel_import('Unable to read the CSV file: xxxxxx') }
    it 'changes the import status' do
      expect { subject }.to change { content_type.reload.import_status }.from(:in_progress).to(:canceled)
    end
  end

  def build_content_type(enabled, raw_import_state)
    build(:content_type, import_enabled: enabled, raw_import_state: raw_import_state).tap do |content_type|
      content_type.entries_custom_fields.build label: 'Title', type: 'string'
      content_type.valid?
    end
  end
end