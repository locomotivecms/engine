module Locomotive
  class Activity
    ## const ##
    UPDATE_ACTIONS = ['deploy']

    include Locomotive::Mongoid::Document

    ## callbacks ##
    after_create :send_notifications, if: :is_an_update?

    ## fields ##
    field :key
    field :parameters,  type: Hash

    ## associations ##
    belongs_to :site,       class_name: 'Locomotive::Site', validate: false, autosave: false
    belongs_to :actor,      class_name: 'Locomotive::Account', validate: false, autosave: false

    ## validations ##
    validates_presence_of :key

    ## indexes ##
    index site_id: 1
    index site_id: 1, created_at: 1

    ## methods ##

    def domain
      self.key.split('.').first
    end

    def action
      self.key.split('.').last
    end

    def is_an_update?
      self.key.in? UPDATE_ACTIONS
    end

    def send_notifications
      ActiveSupport::Notifications.instrument 'deploy', {
        site: site,
        actor: actor
      }
    end

  end
end
