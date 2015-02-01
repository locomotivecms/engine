module Locomotive
  class BaseEntity < Grape::Entity

    def save!
      object.save!
    end

    def update_attribute(attribute, value)
      object.send("#{attribute}=", value)
    end

    private

    def persistence_klass
      self.class.name.gsub(/Entity/,'').constantize
    end
  end
end
