class Project

  include Mongoid::Document
  include CustomFields::ProxyClassEnabler
  include CustomFields::CustomFieldsFor

  field :name
  field :description

  references_many :people
  embeds_many :tasks

  custom_fields_for :people
  custom_fields_for :tasks

  scope :ordered, :order_by => [[:name, :asc]]

end