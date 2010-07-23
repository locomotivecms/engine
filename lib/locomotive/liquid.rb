%w{. tags drops filters}.each do |dir|
  Dir[File.join(File.dirname(__FILE__), 'liquid', dir, '*.rb')].each { |lib| require lib }
end

::Liquid::Template.file_system = Locomotive::Liquid::DbFileSystem.new # enable snippets
