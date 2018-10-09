module Locomotive
  class RoleService < Struct.new(:site, :account)

    include Locomotive::Concerns::ActivityService

    def create(attributes, raise_if_not_valid = false)
      attributes[:name] = attributes[:name].to_s.downcase
      site.roles.new(attributes).tap do |role|
        success = raise_if_not_valid ? role.save! : role.save
        track_activity 'role.created', parameters: { name: role.name.capitalize } if success
      end
    end

    def create!(attributes)
      create(attributes, true)
    end

    def update(role, attributes, raise_if_not_valid = false)
      attributes[:name] = attributes[:name].to_s.downcase
      role.attributes = attributes
      success = raise_if_not_valid ? role.save! : role.save
      track_activity 'role.updated', parameters: { name: role.name.capitalize } if success
    end

    def update!(role, attributes)
      update(site, attributes, true)
    end

  end
end