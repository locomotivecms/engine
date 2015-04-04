module Locomotive
  module API

    class EditableElementEntity < BaseEntity

      expose :slug, :block, :hint, :priority, :from_parent, :disabled

      with_options(format_with: :labelize) do
        expose :label do |editable_entity, _|
          editable_entity.slug
        end
      end

      # it appears that _type on editable element is not funcitonal.
      # expose :type do |editable_entity, _|
      #   editable_entity._type.to_s.demodulize
      # end

      expose :block_name do |editable_entity, _|
        if (block = editable_entity.block)
          with_options(format_with: :labelize) do
            block.split('/').last
          end
        else
          I18n.t('locomotive.pages.form.default_block')
        end
      end

    end

  end
end
