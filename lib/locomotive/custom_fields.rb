# Set correct paths
module CustomFields
  module Types
    module File
      class FileUploader < ::CarrierWave::Uploader::Base

        def store_dir
          "sites/#{model.site_id}/contents/#{model.class.model_name.underscore}/#{model.id}/files"
        end

        def cache_dir
          "#{Rails.root}/tmp/uploads"
        end

      end
    end

    module Category # TODO: patch to apply in the next CustomFields version

      module InstanceMethods

        def category_to_hash
          { 'category_items' => self.category_items.collect(&:to_hash) }
        end

      end

      class Item

        def to_hash(more = {})
          self.fields.keys.inject({}) do |memo, meth|
            memo[meth] = self.send(meth.to_sym); memo
          end.merge({
            'id'          => self._id,
            'new_record'  => self.new_record?,
            'errors'      => self.errors
          }).merge(more)
        end

        def to_json
          self.to_hash.to_json
        end

      end
    end
  end

  class Field # TODO: patch to apply in the next CustomFields version

    after_save :invalidate_klass

    def to_hash_with_types(more = {})
      to_hash_without_types(more).tap do |hash|
        self.class.field_types.keys.each do |type|
          if self.respond_to?(:"#{type}_to_hash")
            hash.merge!(self.send(:"#{type}_to_hash"))
          end
        end
      end
    end

    alias_method_chain :to_hash, :types

    protected

    def invalidate_klass
      target_name = self.association_name.to_s.gsub('_custom_fields', '')
      self._parent.send(:"invalidate_#{target_name}_klass")
    end

  end

end


