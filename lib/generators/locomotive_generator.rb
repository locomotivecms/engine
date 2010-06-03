class LocomotiveGenerator < Rails::Generators::Base
  class_option :update, :type => :boolean, :default => false,
                        :desc => "Just update public files, do not create seed"

  def self.source_root
    @_locomotive_source_root ||= File.dirname(__FILE__)
  end

  def copy_public_files
    directory "../../public", "public", :recursive => true
    exit(0) if options.update?
  end

end