module Locomotive
  class CustomFieldFinderService < Struct.new(:content_type)

    delegate :custom_field, to: :content_type
    delegate :find_by_name, to: :custom_field

  end
end
