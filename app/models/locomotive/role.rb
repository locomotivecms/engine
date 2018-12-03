module Locomotive
  class Role

    include Locomotive::Mongoid::Document

    ## Extensions ##
    include Concerns::Role::RoleModels
    include Concerns::Role::RolePages

    belongs_to  :site,            class_name: 'Locomotive::Site'

    ## behaviours ##
    #accepts_nested_attributes_for :role_models,:role_pages, allow_destroy: true

    field :name ,           type: String,   default: ''

    def is_admin?
        self.try(:name) == 'admin'
    end

  end
end