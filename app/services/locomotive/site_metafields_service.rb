module Locomotive

  class SiteMetafieldsService < Struct.new(:site, :account)

    include Locomotive::Concerns::ActivityService

    def update_all(attributes)
      each_metafield(attributes) do |namespace_name, namespace, name, value|
        next unless field = find_metafield_in(namespace_name, name)

        if field['localized']
          namespace[name] = (namespace[name] || {}).merge(locale.to_s => value)
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
          yield(_name, namespace, name, value)
        end
      end
    end

    # Metafield names are only unique within a namespace ("address" exists in
    # both "contacts" and "mailer_settings", for example), so resolving a field
    # by name alone (Site#find_metafield) can return the definition from another
    # namespace and apply the wrong `localized` flag — persisting a per-locale
    # Hash where a plain scalar was expected.
    def find_metafield_in(namespace_name, name)
      schema = site.metafields_schema.find do |s|
        site.normalize_metafield_name(s['name']) == namespace_name
      end
      return nil unless schema

      schema['fields'].find do |f|
        site.normalize_metafield_name(f['name']) == name
      end
    end

    def locale
      ::Mongoid::Fields::I18n.locale
    end

  end
end
