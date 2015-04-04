require 'spec_helper'

describe Locomotive::TranslationEntity do

  subject { Locomotive::TranslationEntity }
  it { is_expected.to represent(:key) }
  it { is_expected.to represent(:values) }

end
