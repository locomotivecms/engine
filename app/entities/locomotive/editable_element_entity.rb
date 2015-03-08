module Locomotive
  class EditableElementEntity < BaseEntity

    expose :slug, :block, :hint, :priority, :from_parent, :disabled

    with_options(format_with: :labelize) do
      expose :label do |editable_entity, _|
        editable_entity.slug
      end
    end

  end
end
