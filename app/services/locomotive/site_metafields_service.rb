module Locomotive

  class SiteMetafieldsService < Struct.new(:site, :account)

    include Locomotive::Concerns::ActivityService

    def update_all(attributes)
      each_metafield(attributes) do |namespace, name, value|
        next unless field = site.find_metafield(name)

        if field['localized']
          (namespace[name] ||= {})[locale] = value
        else
          namespace[name] = value
        end
      end

      if site.save
        track_activity 'site_metafields.updated'
      end
    end

    protected

    def each_metafield(attributes, &block)
      return if attributes.blank?

      attributes.each do |_name, _attributes|
        site.metafields[_name] ||= {}
        namespace = site.metafields[_name]

        _attributes.each do |name, value|
          yield(namespace, name, value)
        end
      end
    end

    def locale
      ::Mongoid::Fields::I18n.locale
    end

  end
end
