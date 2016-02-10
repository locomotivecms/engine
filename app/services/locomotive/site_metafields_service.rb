module Locomotive

  class SiteMetafieldsService < Struct.new(:site, :account)

    def update_all(attributes)
      each_metafield(attributes) do |namespace, name, value|
        next unless field = site.metafield_info(name)

        if field['localized']
          (namespace[name] ||= {})[locale] = value
        else
          namespace[name] = value
        end
      end

      site.save
    end

    protected

    def each_metafield(attributes, &block)
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
