require 'spec_helper'

describe Locomotive::API::Entities::SnippetEntity do

  subject { described_class }

  before { Time.zone = ActiveSupport::TimeZone['Chicago'] }

  it { is_expected.to represent(:name) }
  it { is_expected.to represent(:slug) }
  it { is_expected.to represent(:template) }

  context 'overrides' do

    let(:snippet) { create(:snippet) }
    subject { described_class.new(snippet) }
    let(:exposure) { subject.serializable_hash }

    describe 'updated_at' do
      it 'runs updated_at through #iso_timestamp' do
        travel_to(Time.zone.local(2015, 4, 1, 12, 0, 0)) do
          expect(exposure[:updated_at]).to eq '2015-04-01T12:00:00Z'
        end
      end
    end

  end

end
