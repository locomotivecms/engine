require 'spec_helper'

describe Locomotive::API::Entities::ContentEntryEntity do

  subject { described_class }

  attributes =
    %i(
      _slug
      _label
      _position
      _visible
      seo_title
      meta_keywords
      meta_description
      content_type_slug
    )

  attributes.each do |exposure|
    it { is_expected.to represent(exposure) }
  end

end
