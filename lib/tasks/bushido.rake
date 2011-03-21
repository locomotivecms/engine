require 'bushido'
require 'jammit'

namespace :bushido do
  desc "Prepare an app to run on the Bushido hosting platform, only called during the initial installation. Called just before booting the app."
  task :install do
    Jammit.package!
  end

  desc "Prepare an app to run on the Bushido hosting platform, called on every update. Called just before booting the app."
  task :update do
    Jammit.package!
  end
end
  
