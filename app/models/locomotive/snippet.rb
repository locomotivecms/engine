module Locomotive
  class Snippet

    include Locomotive::Mongoid::Document
    include Concerns::Shared::Slug

    ## fields ##
    field :name
    field :slug
    field :template, localize: true

    ## associations ##
    belongs_to :site, class_name: 'Locomotive::Site', validate: false, autosave: false

    ## validations ##
    validates_presence_of   :site, :name, :slug, :template
    validates_uniqueness_of :slug, scope: :site_id

    ## behaviours ##
    slugify_from    :name

    ## methods ##

  end
end
