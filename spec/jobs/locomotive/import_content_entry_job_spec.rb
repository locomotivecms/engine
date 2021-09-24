require 'spec_helper'

describe Locomotive::ImportContentEntryJob do

  let(:job) { described_class.new }

  describe '#perform' do

    let(:content_type_id) { 'content-type-id' }
    let(:csv_asset_id) { 'content-asset-id' }
    let(:csv_options) { {} }

    subject { job.perform(content_type_id, csv_asset_id, csv_options) }

    it 'runs the import' do
      expect(Locomotive::ContentType).to receive(:find).with('content-type-id')
      expect_any_instance_of(Locomotive::ContentEntryImportService).to receive(:import).with('content-asset-id', {})
      subject
    end

  end

end