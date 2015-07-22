module Locomotive
  class Activity

    include Locomotive::Mongoid::Document

    ## fields ##
    field :key
    field :parameters,  type: Hash

    ## associations ##
    belongs_to :site,       class_name: 'Locomotive::Site', validate: false, autosave: false
    belongs_to :actor,      class_name: 'Locomotive::Account', validate: false, autosave: false
    belongs_to :recipient,  polymorphic: true, validate: false, autosave: false

    ## validations ##
    validates_presence_of :key, :actor

  end
end
