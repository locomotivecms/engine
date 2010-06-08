class Project
  
  include Mongoid::Document
  include CustomFields::ProxyClassEnabler
  include CustomFields::CustomFieldsFor
  
  field :name
  field :description
  
  has_many_related :people
  embeds_many :tasks
  
  custom_fields_for :people
  custom_fields_for :tasks
  
end