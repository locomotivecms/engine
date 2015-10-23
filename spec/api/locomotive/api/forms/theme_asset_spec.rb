require 'spec_helper'

describe Locomotive::API::Forms::ThemeAssetForm do

  let(:attributes) { { source: { name: 'picture.jpg', content_type: 'image/png' }, folder: 'images', checksum: 42 } }
  let(:form) { described_class.new(attributes) }

  describe '#serializable_hash' do

    subject { form.serializable_hash }

    it { is_expected.to eq('folder' => 'images', 'source' => { 'name' => 'picture.jpg', 'content_type' => 'image/png' }, 'checksum' => 42) }

    it { expect(subject.keys).to eq(['folder', 'source', 'checksum']) }

  end

end
