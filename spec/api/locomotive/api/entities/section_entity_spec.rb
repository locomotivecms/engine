require 'spec_helper'

describe Locomotive::API::Entities::SectionEntity do

  subject { described_class }

  before { Time.zone = ActiveSupport::TimeZone['Chicago'] }

  it { is_expected.to represent(:name) }
  it { is_expected.to represent(:slug) }
  it { is_expected.to represent(:template) }
  it { is_expected.to represent(:definition) }

end
