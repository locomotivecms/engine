class LocomotiveGenerator < Rails::Generators::NamedBase
  class_option :update, :type => :boolean, :default => false,
                        :desc => "Just update public files, do not create seed"

  def self.source_root
    @_locomotive_source_root ||= File.dirname(__FILE__)
  end

  def copy_public_files
    directory "../../public", "public", :recursive => true
    exit(0) if options.update?
  end
  
  

#   def invoke_model
#     invoke "model", [name].concat(migration_columns),
#       :timestamps => false, :test_framework => false, :migration => options.migration?
#   end
# 
#   def add_model_config
#     inject_into_class "app/models/#{file_name}.rb", class_name, <<-CONTENT
#   include RailsMetrics::ORM::#{Rails::Generators.options[:rails][:orm].to_s.camelize}
# CONTENT
#   end
# 
#   def add_application_config
#     inject_into_class "config/application.rb", "Application", <<-CONTENT
#     # Set rails metrics store
#     config.rails_metrics.set_store = lambda { ::#{class_name} }
# 
# CONTENT
#   end

end