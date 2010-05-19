module Admin::CustomFieldsHelper
  
  # def options_for_field_kind(selected = nil)
  #   # %w{String Text Boolean Email File Date}
  #   options = %w{String Text}.map do |kind|
  #     [t("admin.custom_fields.kind.#{kind.downcase}"), kind]
  #   end    
  #   options_for_select(options, selected)
  # end
  
  def options_for_field_kind(selected = nil)
    # %w{String Text Boolean Email File Date}
    options = %w{String Text}.map do |kind|
      [t("admin.custom_fields.kind.#{kind.downcase}"), kind]
    end    
  end
  
end