require 'active_support/dependencies'

module ActiveSupport::Dependencies

  alias_method :require_or_load_without_multiple, :require_or_load

  def require_or_load(file_name, const_path = nil)
    if file_name.starts_with?(Rails.root.to_s + '/app')
      relative_name = file_name.gsub(Rails.root.to_s, '')
      @engine_paths ||= Rails::Application::Railties.engines.collect{|engine| engine.config.root.to_s }
      @engine_paths.each do |path|
        engine_file = File.join(path, relative_name)
        require_or_load_without_multiple(engine_file, const_path) if File.file?(engine_file)
      end
    end
    require_or_load_without_multiple(file_name, const_path)
  end

end
