namespace :locomotive do

  desc 'Fetch the Locomotive default site template for the installation'
  task :fetch_default_site_template => :environment do
    puts "Downloading default site template from '#{Locomotive::Import.DEFAULT_SITE_TEMPLATE}'"
    `curl -L -s -o #{Rails.root}/tmp/default_site_template.zip #{Locomotive::Import.DEFAULT_SITE_TEMPLATE}`
    puts '...done'
  end

end


