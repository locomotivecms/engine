module Locomotive
  class Activity

    include Locomotive::Mongoid::Document

    ## fields ##
    field :key
    field :parameters,  type: Hash

    ## associations ##
    belongs_to :site,   class_name: 'Locomotive::Site', validate: false, autosave: false
    belongs_to :owner,  class_name: 'Locomotive::Account', validate: false, autosave: false
    belongs_to :recipient, polymorphic: true, validate: false, autosave: false

  end
end
