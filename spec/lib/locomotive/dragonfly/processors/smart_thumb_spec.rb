# encoding: utf-8

describe Locomotive::Dragonfly::Processors::SmartThumb do

  let(:thumb) { described_class.new }

  describe '#args_for_geometry' do

    let(:geometry) { '3840x5760|1920x320+10+10' }

    subject { thumb.send(:args_for_geometry, geometry) }

    it 'returns ImageMagick instructions to resize and then crop manually an image' do
      is_expected.to eq '-resize 3840x5760^^ -gravity Northwest -crop 1920x320+10+10 +repage'
    end

    context 'another geometry' do

      let(:geometry) { '3840x2968|1920x320-583+845' }

      it 'returns ImageMagick instructions to resize and then crop manually an image' do
      is_expected.to eq '-resize 3840x2968^^ -gravity Northwest -crop 1920x320-583+845 +repage'
    end

    end

  end

end
