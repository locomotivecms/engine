account = Account.create! :name => 'Admin', :email => 'admin@locomotiveapp.org', :password => 'locomotive', :password_confirmation => 'locomotive'

site = Site.new :name => 'Locomotive test website', :subdomain => 'test'
site.memberships.build :account => account, :admin => true
site.save!
