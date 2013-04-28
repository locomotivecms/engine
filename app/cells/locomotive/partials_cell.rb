module Locomotive
  class PartialsCell < Cell::Rails
    cattr_accessor :templates

    def self.add_template(namespace, name)
      self.templates ||= {}
      self.templates[namespace] ||= []
      self.templates[namespace] << name
    end

    def display(namespace, locals = {})
      return unless self.class.templates && self.class.templates[namespace].present?

      locals.each_pair do |k,v|
        instance_variable_set("@#{k}", v)
      end

      self.class.templates[namespace].map { |template| render view: template }.join.html_safe
    end
  end
end