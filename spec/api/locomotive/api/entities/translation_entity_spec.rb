require 'spec_helper'

describe Locomotive::API::Entities::TranslationEntity do

  subject { described_class }

  it { is_expected.to represent(:key) }
  it { is_expected.to represent(:values) }

end
