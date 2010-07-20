$:.unshift File.expand_path(File.dirname(__FILE__))

require 'active_support'
require 'carrierwave/orm/mongoid'

require 'custom_fields/extensions/mongoid/hierarchy'
require 'custom_fields/extensions/mongoid/associations/proxy'
require 'custom_fields/extensions/mongoid/associations/references_many'
require 'custom_fields/extensions/mongoid/associations/embeds_many'
require 'custom_fields/types/default'
require 'custom_fields/types/string'
require 'custom_fields/types/text'
require 'custom_fields/types/category'
require 'custom_fields/types/boolean'
require 'custom_fields/types/date'
require 'custom_fields/types/file'
require 'custom_fields/proxy_class_enabler'
require 'custom_fields/field'
require 'custom_fields/custom_fields_for'

module Mongoid
  module CustomFields  
    extend ActiveSupport::Concern
    included do
      include ::CustomFields::CustomFieldsFor
    end  
  end
end
