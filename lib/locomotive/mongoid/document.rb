module Locomotive
  
  module Mongoid
  
    module Document
    
      extend ActiveSupport::Concern

      included do
        include ::Mongoid::Document
        include ::Mongoid::Timestamps
        include ::Mongoid::CustomFields
        include Locomotive::Liquid::LiquifyTemplate
      end
    
    end
  
  end
  
end