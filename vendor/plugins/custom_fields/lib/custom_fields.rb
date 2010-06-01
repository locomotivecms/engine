$:.unshift File.expand_path(File.dirname(__FILE__))

require 'custom_fields/extensions/mongoid/associations/embeds_many'
require 'custom_fields/extensions/mongoid/document'
require 'custom_fields/custom_fields_for'

module Mongoid
  module CustomFields  
    extend ActiveSupport::Concern
    included do
      include ::CustomFields::CustomFieldsFor
    end  
  end
end
